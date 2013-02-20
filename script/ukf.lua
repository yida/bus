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
-- local dataset = loadData(datasetpath, 'imugps')

emptyState = torch.DoubleTensor(13, 1):fill(0)
emptyState[7] = 1
-- state init Posterior state
state = torch.DoubleTensor(13, 1):copy(emptyState) -- x, y, z, vx, vy, vz, q0, q1, q2, q3, wx, wy, wz
state[7] = 0
state[8] = 1
state[9] = 0
state[10] = 0
-- state Cov, Posterior
P = torch.eye(12):mul(0.0001)
Q = torch.eye(12):mul(0.0001)
R = torch.eye(12):mul(1)

ns = 12
Chi = torch.DoubleTensor(state:size(1), 2 * ns + 1):fill(0)
statePriori = torch.DoubleTensor(13, 1):fill(0)
PPrioro = torch.eye(12, 12):mul(1)
e = torch.DoubleTensor(3, 2 * ns + 1):fill(0)
Y = torch.DoubleTensor(state:size(1), 2 * ns + 1):fill(0)
Z = torch.DoubleTensor(state:size(1), 2 * ns + 1):fill(0)
zMean = torch.DoubleTensor(13, 1):fill(0)
v = torch.DoubleTensor(12, 1):fill(0)
Pzz = torch.eye(12):mul(1)
Pvv = torch.eye(12):mul(1)
Pxz = torch.eye(12):mul(1)
K = torch.DoubleTensor(12, 12):fill(0)
e = torch.DoubleTensor(3, 2 * ns + 1):fill(0)

-- Imu Init
accBiasX = -0.03
accBiasY = 0
accBiasZ = 0
acc = torch.DoubleTensor(3, 1):fill(0)
gyro = torch.DoubleTensor(3, 1):fill(0)

g = 0
gInitCount = 0
gInitCountMax = 100

processInit = false
gravityInit = false
gravity = 9.80
imuTstep = 0

function PrioriEstimate()
  -- Generate priori estimate state and covariance
  -- Get mean of pos, vel and avel
  state:narrow(1, 1, 6):copy(torch.mean(Y:narrow(1, 1, 6), 2))
  state:narrow(1, 11, 3):copy(torch.mean(Y:narrow(1, 11, 3), 2))

  local qIter = torch.DoubleTensor(4, 1):copy(state:narrow(1, 7, 4))
  repeat
    e:fill(0)
    for i = 1, 2 * ns + 1 do
      local ei = e:narrow(2, i, 1):fill(0)
      local qi = torch.DoubleTensor(4):copy(Y:narrow(2, i, 1):narrow(1, 7, 4))
      local eQ = QuaternionMul(qi, QInverse(qIter))
      ei:copy(Q2Vector(eQ))
    end
    local eMean = torch.mean(e,2)
    local qIterNext = QuaternionMul(Vector2Q(eMean), qIter)
    local qIterDiff = qIterNext - qIter
    qIter:copy(qIterNext)
  until QCompare(qIterDiff, 0.001)
  state:narrow(1, 7, 4):copy(qIter)

  print(state)

  print('priori estimate '..tostring(utime()))
--  print(Chi)
  PPrioro:fill(0)
  for i = 1, 2 * ns + 1 do
    local Chicol = Chi:narrow(2, i, 1)
    local WDiff = torch.DoubleTensor(12, 1):fill(0)
    -- Pos & Vel
    WDiff:narrow(1, 1, 6):copy(Chicol:narrow(1, 1, 6))
    WDiff:narrow(1, 1, 6):add(-state:narrow(1, 1, 6))
    -- Angular Vel
    WDiff:narrow(1, 9, 3):copy(Chicol:narrow(1, 11, 3))
    WDiff:narrow(1, 9, 3):add(-state:narrow(1, 11, 3))
    -- Rotation
    WDiff:narrow(1, 7, 3):copy(e:narrow(2, i, 1))
--    print(WDiff)
    PPrioro:add(WDiff * WDiff:t())
  end
  --print(PPrioro)
  PPrioro:div(2 * ns + 1)
  P:copy(PPrioro)
--  print(PPrioro)

  print(P)

end

function ProcessModel(dt)
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
    omega:copy(gyro)
    
    local q = Chicol:narrow(1, 7, 4)
    local dq = Vector2Q(gyro, dt)
    Ycol:narrow(1, 7, 4):copy(QuaternionMul(q,dq))
  end
--  print(Y)
end

function GenerateSigmaPoints()
  -- Sigma points
--  print(cholesky(P+Q):t())
  local W = cholesky(P+Q):t():mul(math.sqrt(2*ns))
  --print(W)
  Chi:narrow(2, 1, 1):copy(state)
  local q = state:narrow(1, 7, 4)
  for i = 2, ns + 1  do
    local Wcol = W:narrow(2, i-1, 1)
    local posChi = Chi:narrow(2, i, 1):copy(state)
    local negChi = Chi:narrow(2, i + ns, 1):copy(state)
    -- Sigma points for pos and vel
    posChi:narrow(1, 1, 6):add(Wcol:narrow(1, 1, 6))
    negChi:narrow(1, 1, 6):add(-Wcol:narrow(1, 1, 6))
    -- Sigma points for angular vel
    posChi:narrow(1, 11, 3):add(Wcol:narrow(1, 10, 3))
    negChi:narrow(1, 11, 3):add(-Wcol:narrow(1, 10, 3))

    -- Sigma points for Quaternion
    local qW = Vector2Q(Wcol:narrow(1, 7, 3))
    local negqW = Vector2Q(-Wcol:narrow(1, 7, 3))
--    print(qW)
--    print(negqW)
    posChi:narrow(1, 7, 4):copy(QuaternionMul(q, qW))
    negChi:narrow(1, 7, 4):copy(QuaternionMul(q, negqW))
  end
--  print(Chi)
end

function processUpdate(tstep, imu)
  local curR = Quaternion2R(state:narrow(1, 7, 4))
  acc[1] = imu.ax - accBiasX
  acc[2] = imu.ay - accBiasY
  acc[3] = imu.az - accBiasZ
  -- Rotate Acc to world coordinate
  acc = curR * acc

  if processInit == false then 
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
  -- substract gravity from z axis and convert from g to m/s^2
  acc[3] = acc[3] - g
  acc:mul(gravity)
  gyro[1] = imu.wr
  gyro[2] = imu.wy
  gyro[3] = imu.wp

  GenerateSigmaPoints()
--  print('sigma points')
--  print(state:t())
  ProcessModel(dt)
--  print('process points')
--  print(state:t())
  PrioriEstimate()
--  print('priori points')
--  print(state:t())  
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
    local zqi = torch.DoubleTensor(4):copy(Zcol:narrow(1, 7, 4))
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
    local yqi = torch.DoubleTensor(4):copy(Ycol:narrow(1, 7, 4))
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
  local stateadd = K * v
  state:narrow(1, 1, 6):copy(stateadd:narrow(1, 1, 6))
  state:narrow(1, 11, 3):copy(stateadd:narrow(1, 10, 3))
  local stateqi = state:narrow(1, 7, 4)
  local stateaddqi = Vector2Q(stateadd:narrow(1, 7, 3))
  state:narrow(1, 7, 4):copy(QuaternionMul(stateqi, stateaddqi))
  P = P - K * Pvv * K:t() 

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

-- Geo Init
firstlat = true
local basepos = {0.0, 0.0, 0.0}
function measurementGPSUpdate(tstep, gps)
  if gps.latitude == nil or gps.latitude == '' then return end
  local lat, lnt = nmea2degree(gps.latitude, gps.northsouth, gps.longtitude, gps.eastwest)
  local gpsposAb = geo.Forward(lat, lnt, 6)

  if firstlat then
      basepos = gpsposAb
      firstlat = false
  end
  local gpspos = torch.DoubleTensor({gpsposAb.x - basepos.x, gpsposAb.y - basepos.y, 0})
--  print(gpspos)
  Z:fill(0)
  for i = 1, 2 * ns + 1 do
    local Zcol = Z:narrow(2, i, 1)
    local Chicol = Chi:narrow(2, i , 1)
    Zcol:narrow(1, 1, 3):copy(Chicol:narrow(1, 1, 3))
  end
  zMean = torch.mean(Z, 2)
  local zk = torch.DoubleTensor(13):fill(0)
  zk:narrow(1, 1, 3):copy(gpspos)
  v = zk - zMean
  R[1][1] = 4
  R[2][2] = 4
  R[3][3] = 4

  KalmanGainUpdate()

end

function measurementMagUpdate()
end

function measurementRotUpdate(tstep, imu)
  local zk = torch.DoubleTensor(13):fill(0)
  zk[11] = imu.wr
  zk[12] = imu.wp
  zk[13] = imu.wy
  Z:fill(0)
  for i = 1, 2 * ns + 1 do
    local Zcol = Z:narrow(2, i, 1)
    local Chicol = Chi:narrow(2, i , 1)
    Zcol:narrow(1, 11, 3):copy(Chicol:narrow(1, 11, 3))
  end
  zMean = torch.mean(Z, 2)
  v = zk - zMean
  R[10][10] = 0.0001
  R[11][11] = 0.0001
  R[12][12] = 0.0001

  KalmanGainUpdate()

end

--local q = torch.DoubleTensor(4):fill(0)

--for i = 1, #dataset do
--for i = 1, #dataset do
--for i = 300, 20000 do
--for i = 300, 494 do
--for i = 300, 496 do
for i = 300, 696 do
  if dataset[i].type == 'imu' then
    processUpdate(dataset[i].timstamp, dataset[i])
    measurementGravityUpdate()
--    measurementRotUpdate(dataset[i].timstamp, dataset[i])
  elseif dataset[i].type == 'gps' then
--    measurementGPSUpdate(dataset[i].timstamp, dataset[i])
  elseif dataset[i].type == 'mag' then
--    measurementMagUpdate(dataset[i].timstamp, dataset[i])
  end
end

print('done')
