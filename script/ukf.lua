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

function QCompare(q, res)
  if math.abs(q[1]) > res then return false end
  if math.abs(q[2]) > res then return false end
  if math.abs(q[3]) > res then return false end
  if math.abs(q[4]) > res then return false end
  return true
end

function QDiff(q1, q2, res)
  print(q1, q2)
  print(math.abs(q1[1] - q2[1]))
  if math.abs(q1[1] - q2[1]) > res then return false end
  if math.abs(q1[2] - q2[2]) > res then return false end
  if math.abs(q1[3] - q2[3]) > res then return false end
  if math.abs(q1[4] - q2[4]) > res then return false end
  return true
end

function Omega2Q(w, dt)
  local dq = torch.DoubleTensor(4):fill(0)
  if w:norm() == 0 then
    return -1
  end
  if dt then
    dAngle = w:norm() * dt
  else
    dAngle = w:norm()
  end
  dAxis = w:div(w:norm()) 
  dq[1] = math.cos(dAngle / 2)
  dq[{{2, 4}}] = dAxis * math.sin(dAngle / 2)
  return dq
end

--state init
state = {}
state = torch.DoubleTensor(13):fill(0) -- x, y, z, vx, vy, vz, q0, q1, q2, q3, wx, wy, wz
state[7] = 1
ns = 12
P = torch.eye(12):mul(10)
Q = torch.eye(12):mul(10)
Chi = torch.DoubleTensor(state:size(1), 2 * ns + 1):fill(0)

-- Imu Init
accBiasX = -0.03
accBiasY = 0
accBiasZ = 0

g = 0
gInitCount = 0
gInitCountMax = 100

processInit = false
gravityInit = false
imuTstep = 0

function processUpdate(tstep, imu)
  acc = torch.DoubleTensor({imu.ax - accBiasX, imu.ay - accBiasY, imu.az - accBiasZ})
  -- Rotate pi on X axes
  acc = torch.mv(rotX(math.pi), acc)

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
  acc[3] = acc[3] - g
  state[11] = imu.wr
  state[12] = imu.wp
  state[13] = imu.wy
  
--  print(acc[1], acc[2], acc[3])
--  state[11] = 2
--  state[12] = 3.2
--  state[13] = 4.3

  -- Sigma points
  W = torch.sqrt((P+Q):mul(2*ns)) 
  Chi:narrow(2, 1, 1):copy(state)
  q = torch.DoubleTensor(4):copy(state:narrow(1, 7, 4))
  for i = 2, ns + 1  do
    WCol = W:narrow(2, i-1, 1)
    posChi = Chi:narrow(2, i, 1):copy(state)
    negChi = Chi:narrow(2, i + ns, 1):copy(state)
    -- Sigma points for pos and vel
    posChi:narrow(1, 1, 6):add(WCol:narrow(1, 1, 6))
    negChi:narrow(1, 1, 6):add(-WCol:narrow(1, 1, 6))
    -- Sigma points for angular vel
    posChi:narrow(1, 11, 3):add(WCol:narrow(1, 10, 3))
    negChi:narrow(1, 11, 3):add(-WCol:narrow(1, 10, 3))

    -- Sigma points for Quaternion
    qW = Omega2Q(WCol:narrow(1, 7, 3))
    negqW = Omega2Q(-WCol:narrow(1, 7, 3))
    if qW ~= -1 and negqW ~= -1 then
      posChi:narrow(1, 7, 4):copy(QuaternionMul(q, qW))
      negChi:narrow(1, 7, 4):copy(QuaternionMul(q, negqW))
    end
  end
  
--  print(Chi)

  -- Process Model Update and generate y
  F = torch.DoubleTensor({{1,0,0,dt,0,0}, {0,1,0,0,dt,0}, {0,0,1,0,0,dt},
                          {0,0,0,1,0,0}, {0,0,0,0,1,0}, {0,0,0,0,0,1}})
  G = torch.DoubleTensor({{dt^2/2,0,0}, {0,dt^2/2,0}, {0,0,dt^2/2},
                          {dt,0,0}, {0,dt,0}, {0,0,dt}})
    -- Y
  Y = torch.DoubleTensor(state:size(1), 2 * ns + 1):fill(0)
  for i = 1, 2 * ns + 1 do
    Chicol = Chi:narrow(2, i, 1)
    Ycol = Y:narrow(2, i, 1)
    posvel = Chicol:narrow(1, 1, 6)

    posvel:copy(F * Chicol:narrow(1, 1, 6) + G * acc)
    omega = Ycol:narrow(1, 11, 3) 
    omega:copy(Chicol:narrow(1, 11, 3))
    
    q = torch.DoubleTensor(4):copy(Chicol:narrow(1, 7, 4))
    dq = Omega2Q(Chicol:narrow(1, 11, 3))
    if dq ~= -1 then
--      print(QuaternionMul(q,dq))
      Ycol:narrow(1, 7, 4):copy(QuaternionMul(q,dq))
    else
      Ycol:narrow(1, 7, 4):copy(Chicol:narrow(1, 7, 4))
    end
  end
--  print(Y)
  -- Generate priori estimate state and covariance
  statePriori = torch.DoubleTensor(state:size()):copy(torch.mean(Y, 2))

  qIter = torch.DoubleTensor(4):copy(state:narrow(1, 7, 4))
  local iter = 0
  repeat
    iter = iter + 1
    e = torch.DoubleTensor(3, 2 * ns + 1):fill(0)
    for i = 1, 2 * ns + 1 do
      ei = e:narrow(2, i, 1):fill(0)
      qi = torch.DoubleTensor(4):copy(Y:narrow(2, i, 1):narrow(1, 7, 4))
      eQ = QuaternionMul(qi, QInverse(qIter))
      alphaW = math.acos(eQ[1])
      if alphaW ~= 0 then
        ei[1] = eQ[2] / math.sin(alphaW) * alphaW
        ei[2] = eQ[3] / math.sin(alphaW) * alphaW
        ei[3] = eQ[4] / math.sin(alphaW) * alphaW
      end
    end
    eMean = torch.DoubleTensor(3):copy(torch.mean(e,2))
    qIterNext = QuaternionMul(Omega2Q(eMean), qIter)
    qIterDiff = qIterNext - qIter
    qIter:copy(qIterNext)
  until QCompare(qIterDiff, 0.001)
  statePriori:narrow(1, 7, 4):copy(qIter)  
  print(Chi)
  print(statePriori)
end


function measurementGPSUpdate()
end

--local q = torch.DoubleTensor(4):fill(0)

-- Geo Init
local firstlat = true
local basepos = {0.0, 0.0, 0.0}

--for i = 1, #dataset do
for i = 1, 500 do
  if dataset[i].type == 'imu' then
    processUpdate(dataset[i].timstamp, dataset[i])
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

  end
end

print('done')
