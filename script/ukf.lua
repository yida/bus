require 'include'
require 'common'
require 'gpscommon'
require 'poseUtils'
require 'torch-load'

local serialization = require('serialization');
local util = require('util');
local geo = require 'GeographicLib'

local datasetpath = '../data/010213180247/'
local dataset = loadData(datasetpath, 'imugps', 10000)
--local dataset = loadData(datasetpath, 'imugps')

--state init
state = {}
state = torch.DoubleTensor(13):fill(0) -- x, y, z, vx, vy, vz, q0, q1, q2, q3, wx, wy, wz
state[8] = 1
ns = 12
P = torch.eye(12):mul(0.0001)
Q = torch.eye(12):mul(0.0001)
R = torch.DoubleTensor(12):fill(0)
Chi = torch.DoubleTensor(state:size(1), 2 * ns + 1):fill(0)
statePriori = torch.DoubleTensor(state:size()):fill(0)
PPrioro = torch.DoubleTensor(12, 12):fill(0)
Y = torch.DoubleTensor(state:size(1), 2 * ns + 1):fill(0)
Z = torch.DoubleTensor(state:size(1), 2 * ns + 1):fill(0)
zMean = torch.DoubleTensor(13):fill(0)
v = torch.DoubleTensor(12):fill(0)
Pzz = torch.DoubleTensor(12, 12):fill(0)
Pvv = torch.DoubleTensor(12, 12):fill(0)
Pxz = torch.DoubleTensor(12, 12):fill(0)
K = torch.DoubleTensor(12, 12):fill(0)

-- Imu Init
accBiasX = -0.03
accBiasY = 0
accBiasZ = 0
acc = torch.DoubleTensor(3):fill(0)

g = 0
gInitCount = 0
gInitCountMax = 100

processInit = false
gravityInit = false
gravity = 9.80
imuTstep = 0

function processUpdate(tstep, imu)
  local curR = Quaternion2R(state:narrow(1, 7, 4))
  acc:copy(torch.DoubleTensor({imu.ax - accBiasX, imu.ay - accBiasY, imu.az - accBiasZ}))
  acc = torch.mv(curR, acc)
  if processInit == false then 
--    print('init')
    processInit = true
    imuTstep = tstep
    return
  end

  local dt = tstep - imuTstep
  if dt == 0 then return end 
  imuTstep = tstep

  if not gravityInit then
    g = g + acc:norm()  
    gInitCount = gInitCount + 1
    if gInitCount >= gInitCountMax then
      print('Initiate Gravity')
      g = g / gInitCount
      gravityInit = true
    else
      return
    end
  end
  -- substract gravity from z axis
  -- Rotate pi on X axes
  acc:add(torch.DoubleTensor({0, 0, -g}))
  acc:mul(gravity)
--  print(acc[1], acc[2], acc[3])
  gyro = torch.DoubleTensor({imu.wr, imu.wp, imu.wy})
  
  -- Sigma points
  local W = torch.sqrt((P+Q):mul(2*ns)) 
  Chi:narrow(2, 1, 1):copy(state)
  local q = torch.DoubleTensor(4):copy(state:narrow(1, 7, 4))
  for i = 2, ns + 1  do
    local WCol = W:narrow(2, i-1, 1)
    local posChi = Chi:narrow(2, i, 1):copy(state)
    local negChi = Chi:narrow(2, i + ns, 1):copy(state)
    -- Sigma points for pos and vel
    posChi:narrow(1, 1, 6):add(WCol:narrow(1, 1, 6))
    negChi:narrow(1, 1, 6):add(-WCol:narrow(1, 1, 6))
    -- Sigma points for angular vel
    posChi:narrow(1, 11, 3):add(WCol:narrow(1, 10, 3))
    negChi:narrow(1, 11, 3):add(-WCol:narrow(1, 10, 3))

    -- Sigma points for Quaternion
    local qW = Vector2Q(WCol:narrow(1, 7, 3))
    local negqW = Vector2Q(-WCol:narrow(1, 7, 3))
    if qW ~= -1 and negqW ~= -1 then
      posChi:narrow(1, 7, 4):copy(QuaternionMul(q, qW))
      negChi:narrow(1, 7, 4):copy(QuaternionMul(q, negqW))
    end
  end
  
  -- Process Model Update and generate y
  local F = torch.DoubleTensor({{1,0,0,dt,0,0}, {0,1,0,0,dt,0}, {0,0,1,0,0,dt},
                          {0,0,0,1,0,0}, {0,0,0,0,1,0}, {0,0,0,0,0,1}})
  local G = torch.DoubleTensor({{dt^2/2,0,0}, {0,dt^2/2,0}, {0,0,dt^2/2},
                          {dt,0,0}, {0,dt,0}, {0,0,dt}})
    -- Y
  for i = 1, 2 * ns + 1 do
    local Chicol = Chi:narrow(2, i, 1)
    local Ycol = Y:narrow(2, i, 1)
    local posvel = Ycol:narrow(1, 1, 6)

    posvel:copy(F * Chicol:narrow(1, 1, 6) + G * acc)
    local omega = Ycol:narrow(1, 11, 3) 
    omega:copy(Chicol:narrow(1, 11, 3))
    
    local q = torch.DoubleTensor(4):copy(Chicol:narrow(1, 7, 4))
    local dq = Vector2Q(gyro)
    if dq ~= -1 then
--      print(QuaternionMul(q,dq))
      Ycol:narrow(1, 7, 4):copy(QuaternionMul(q,dq))
    else
      Ycol:narrow(1, 7, 4):copy(Chicol:narrow(1, 7, 4))
    end
  end
  -- Generate priori estimate state and covariance
  statePriori:copy(torch.mean(Y, 2))

  local qIter = torch.DoubleTensor(4):copy(state:narrow(1, 7, 4))
  repeat
    e = torch.DoubleTensor(3, 2 * ns + 1):fill(0)
    for i = 1, 2 * ns + 1 do
      local ei = e:narrow(2, i, 1):fill(0)
      local qi = torch.DoubleTensor(4):copy(Y:narrow(2, i, 1):narrow(1, 7, 4))
      local eQ = QuaternionMul(qi, QInverse(qIter))
      ei:copy(Q2Vector(eQ))
    end
    local eMean = torch.DoubleTensor(3):copy(torch.mean(e,2))
    local qIterNext = QuaternionMul(Vector2Q(eMean), qIter)
    local qIterDiff = qIterNext - qIter
    qIter:copy(qIterNext)
  until QCompare(qIterDiff, 0.001)
  statePriori:narrow(1, 7, 4):copy(qIter)  

  PPrioro:fill(0)
  for i = 1, 2 * ns + 1 do
    local Chicol = Chi:narrow(2, i, 1)
    local WDiff = torch.DoubleTensor(12, 1):fill(0)
    -- Pos & Vel
    WDiff:narrow(1, 1, 6):copy(Chicol:narrow(1, 1, 6))
    WDiff:narrow(1, 1, 6):add(-statePriori:narrow(1, 1, 6))
    -- Angular Vel
    WDiff:narrow(1, 9, 3):copy(Chicol:narrow(1, 11, 3))
    WDiff:narrow(1, 9, 3):add(-statePriori:narrow(1, 11, 3))
    -- Rotation
    WDiff:narrow(1, 7, 3):copy(e:narrow(2, i, 1))
    PPrioro:add(WDiff * WDiff:t())
  end
  PPrioro:div(2 * ns + 1)
--  print(PPrioro)

--  print(statePriori)
end

function KalmanGainUpdate()
  -- Pzz, Pvv
  Pzz:fill(0)
  for i = 1, 2 * ns + 1 do
    local Zcol = Z:narrow(2, i, 1)
    local ZDiff = torch.DoubleTensor(12, 1):fill(0)
     -- Pos & Vel
    ZDiff:narrow(1, 1, 6):copy(Zcol:narrow(1, 1, 6))
    ZDiff:narrow(1, 1, 6):add(-zMean:narrow(1, 1, 6))
    -- Angular Vel
    ZDiff:narrow(1, 9, 3):copy(Zcol:narrow(1, 11, 3))
    ZDiff:narrow(1, 9, 3):add(-zMean:narrow(1, 11, 3))

    -- Rotation
    local zqi = Zcol:narrow(1, 7, 4)
    local zqMean = zMean:narrow(1, 7, 4)
    local zqDiff = QuaternionMul(zqi, QInverse(zqMean))
    local ze = Q2Vector(zqDiff)
    ZDiff:narrow(1, 7, 3):copy(ze)

    Pzz:add(ZDiff * ZDiff:t())
  end
  Pzz:div(2 * ns + 1)
  Pvv = Pzz + R

  -- Pxz
  Pxz:fill(0)
  for i = 1, 2 * ns + 1 do
    local Ycol = Y:narrow(2, i, 1)
    local WDiff = torch.DoubleTensor(12, 1):fill(0)
    -- Pos & Vel
    WDiff:narrow(1, 1, 6):copy(Ycol:narrow(1, 1, 6))
    WDiff:narrow(1, 1, 6):add(-statePriori:narrow(1, 1, 6))
    -- Angular Vel
    WDiff:narrow(1, 9, 3):copy(Ycol:narrow(1, 11, 3))
    WDiff:narrow(1, 9, 3):add(-statePriori:narrow(1, 11, 3))
    -- Rotation
    WDiff:narrow(1, 7, 3):copy(e:narrow(2, i, 1))
    -- Rotation
    local yqi = Ycol:narrow(1, 7, 4)
    local yqMean = statePriori:narrow(1, 7, 4)
    local yqDiff = QuaternionMul(yqi, QInverse(yqMean))
    local ye = Q2Vector(yqDiff)
    WDiff:narrow(1, 7, 3):copy(ye)


    local Zcol = Z:narrow(2, i, 1)
    local ZDiff = torch.DoubleTensor(12, 1):fill(0)
     -- Pos & Vel
    ZDiff:narrow(1, 1, 6):copy(Zcol:narrow(1, 1, 6))
    ZDiff:narrow(1, 1, 6):add(-zMean:narrow(1, 1, 6))
    -- Angular Vel
    ZDiff:narrow(1, 9, 3):copy(Zcol:narrow(1, 11, 3))
    ZDiff:narrow(1, 9, 3):add(-zMean:narrow(1, 11, 3))

    -- Rotation
    local zqi = Zcol:narrow(1, 7, 4)
    local zqMean = zMean:narrow(1, 7, 4)
    local zqDiff = QuaternionMul(zqi, QInverse(zqMean))
    local ze = Q2Vector(zqDiff)
    ZDiff:narrow(1, 7, 3):copy(ze)
    
    Pxz:add(WDiff * ZDiff:t())
  end
  Pxz:div(2 * ns + 1)

  -- K
  K = Pxz * torch.inverse(Pvv)

  -- posterior
  state = statePriori + K * v
  P = PPrioro - K * Pvv * K:t() 

end

function measurementGravityUpdate()
  if not gravityInit then return end
  local gv = torch.DoubleTensor({0,0, gravity * g})
  local gq = Vector2Q(gv)
  for i = 1, 2 * ns + 1 do
    local Zcol = Z:narrow(2, i, 1)
    local Chicol = Chi:narrow(2, i , 1)
    local qk = torch.DoubleTensor(4):copy(Chicol:narrow(1, 7, 4))
--    print(QuaternionMul(QuaternionMul(qk, gq), QInverse(qk)))
    Zcol:narrow(1, 7, 4):copy(QuaternionMul(QuaternionMul(qk, gq), QInverse(qk)))
  end

  local qIter = torch.DoubleTensor(4):copy(gq)
  local iter = 0
  repeat
    iter = iter + 1
    local e = torch.DoubleTensor(3, 2 * ns + 1):fill(0)
    for i = 1, 2 * ns + 1 do
      local ei = e:narrow(2, i, 1):fill(0)
      local qi = torch.DoubleTensor(4):copy(Z:narrow(2, i, 1):narrow(1, 7, 4))
      local eQ = QuaternionMul(qi, QInverse(qIter))
      ei:copy(Q2Vector(eQ))
    end
    local eMean = torch.DoubleTensor(3):copy(torch.mean(e,2))
    local qIterNext = QuaternionMul(Vector2Q(eMean), qIter)
    local qIterDiff = qIterNext - qIter
    qIter:copy(qIterNext)
  until QCompare(qIterDiff, 0.001)
  zMean:fill(0)
  zMean:narrow(1, 7, 4):copy(qIter)

  R:fill(0)
  R[7][7] = 0.0001
  R[8][8] = 0.0001 
  R[8][8] = 0.0001

  v:fill(0)
  local gq = Vector2Q(acc)
  local zqMean = zMean:narrow(1, 7, 4)
  local vv = Q2Vector(QuaternionMul(gq, QInverse(zqMean)))
  v:narrow(1, 7, 3):copy(vv)

  KalmanGainUpdate()
end

function measurementGPSUpdate()
end

function measurementMagUpdate()
end

function measurementRotUpdate()
end

--local q = torch.DoubleTensor(4):fill(0)

-- Geo Init
local firstlat = true
local basepos = {0.0, 0.0, 0.0}

for i = 1, #dataset do
--for i = 1, 500 do
  if dataset[i].type == 'imu' then
    processUpdate(dataset[i].timstamp, dataset[i])
    measurementGravityUpdate()
    measurementRotUpdate()
  elseif dataset[i].type == 'gps' then
    if dataset[i].latitude and dataset[i].latitude ~= '' then
      lat, lnt = nmea2degree(dataset[i].latitude, dataset[i].northsouth, 
                              dataset[i].longtitude, dataset[i].eastwest)
      gpspos = geo.Forward(lat, lnt, 6)
      if firstlat then
        basepos = gpspos
        firstlat = false
      else
        gpsposition = torch.DoubleTensor({gpspos.x - basepos.x, gpspos.y - basepos.y, 0})
        measurementGPSUpdate(gpsposition)
      end
    end
  elseif dataset[i].type == 'mag' then
    measurementMagUpdate()
  end
end

print('done')
