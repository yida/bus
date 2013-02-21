require 'include'
require 'common'
require 'gpscommon'
require 'poseUtils'
require 'torch-load'

local serialization = require('serialization');
local util = require('util');
local geo = require 'GeographicLib'

local datasetpath = '../data/010213180247/'
--local dataset = loadData(datasetpath, 'imugps', 10000)
local dataset = loadData(datasetpath, 'imugps')

emptyState = torch.DoubleTensor(13, 1):fill(0)
emptyState[7] = 1
-- state init Posterior state
state = torch.DoubleTensor(13, 1):copy(emptyState) -- x, y, z, vx, vy, vz, q0, q1, q2, q3, wx, wy, wz
state[7] = 0
state[8] = 1
state[9] = 0
state[10] = 0

-- state Cov, Posterior
P = torch.DoubleTensor(12, 12):fill(0) -- estimate error covariance
posCov = torch.eye(3, 3):mul(0.5^2)
velCov = torch.eye(3, 3):mul(0.1^2)
qCov   = torch.eye(3, 3):mul((10 * math.pi / 180)^2)
omegaCov = torch.eye(3, 3):mul(0.01^2)
P:narrow(1, 1, 3):narrow(2, 1, 3):copy(posCov)
P:narrow(1, 4, 3):narrow(2, 4, 3):copy(velCov)
P:narrow(1, 7, 3):narrow(2, 7, 3):copy(qCov)
P:narrow(1, 10, 3):narrow(2, 10, 3):copy(omegaCov)

--Q = torch.eye(12):mul(1) -- process noise covariance
Q = torch.DoubleTensor(12, 12):fill(0) -- process noise covariance
posCov = torch.eye(3, 3):mul(0.5^2)
velCov = torch.eye(3, 3):mul(0.1^2)
qCov   = torch.eye(3, 3):mul((10 * math.pi / 180)^2)
omegaCov = torch.eye(3, 3):mul(0.01^2)
Q:narrow(1, 1, 3):narrow(2, 1, 3):copy(posCov)
Q:narrow(1, 4, 3):narrow(2, 4, 3):copy(velCov)
Q:narrow(1, 7, 3):narrow(2, 7, 3):copy(qCov)
Q:narrow(1, 10, 3):narrow(2, 10, 3):copy(omegaCov)

--R = torch.DoubleTensor(12, 12):fill(0) -- measurement noise covariance
posCovR = torch.eye(3, 3):mul(2^2)
velCovR = torch.eye(3, 3):mul(0.1^2)
qCovR   = torch.eye(3, 3):mul((10 * math.pi / 180)^2)
omegaCovR = torch.eye(3, 3):mul(0.01^2)

ns = 12
Chi = torch.DoubleTensor(state:size(1), 2 * ns):fill(0)
ChiMean = torch.DoubleTensor(13, 1):fill(0)
e = torch.DoubleTensor(3, 2 * ns + 1):fill(0)
Y = torch.DoubleTensor(state:size(1), 2 * ns):fill(0)
yMean = torch.DoubleTensor(13, 1):fill(0)
e = torch.DoubleTensor(3, 2 * ns):fill(0)

-- Imu Init
accBiasX = -0.03
accBiasY = 0
accBiasZ = 0
acc = torch.DoubleTensor(3, 1):fill(0)
gacc = torch.DoubleTensor(3, 1):fill(0)
gyro = torch.DoubleTensor(3, 1):fill(0)

g = 0
gInitCount = 0
gInitCountMax = 100

processInit = false
gravityInit = false
gravity = 9.80
imuTstep = 0

function GenerateSigmaPoints()
  -- Sigma points
  local W = cholesky((P+Q):mul(math.sqrt(2*ns)))
  local q = state:narrow(1, 7, 4)
  for i = 1, ns  do
    local Wcol = W:narrow(2, i, 1)
    local posChi = Chi:narrow(2, i, 1):copy(state)
    local negChi = Chi:narrow(2, i + ns, 1):copy(state)
    -- Sigma points for pos and vel
    posChi:narrow(1, 1, 6):add(Wcol:narrow(1, 1, 6))
    negChi:narrow(1, 1, 6):add(-Wcol:narrow(1, 1, 6))
--    -- Sigma points for angular vel
    posChi:narrow(1, 11, 3):add(Wcol:narrow(1, 10, 3))
    negChi:narrow(1, 11, 3):add(-Wcol:narrow(1, 10, 3))

    -- Sigma points for Quaternion
    local qW = Vector2Q(Wcol:narrow(1, 7, 3))
    local negqW = Vector2Q(-Wcol:narrow(1, 7, 3))
    posChi:narrow(1, 7, 4):copy(QuaternionMul(q, qW))
    negChi:narrow(1, 7, 4):copy(QuaternionMul(q, negqW))
  end
end

function processUpdate(tstep, imu)
  local curR = Quaternion2R(state:narrow(1, 7, 4))
  gacc[1] = imu.ax - accBiasX
  gacc[2] = imu.ay - accBiasY
  gacc[3] = imu.az - accBiasZ
  -- Rotate Acc to world coordinate
  gacc = curR * gacc

  if processInit == false then 
    processInit = true
    imuTstep = tstep
    return
  end

  local dt = tstep - imuTstep
  if dt == 0 then return end 
  imuTstep = tstep

  if not gravityInit then
    g = g + gacc:norm()  
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
  acc:copy(gacc)
  acc[3] = acc[3] - g
  acc = acc * gravity
  acc:mul(gravity)
  gyro[1] = imu.wr
  gyro[2] = imu.wy
  gyro[3] = imu.wp

  GenerateSigmaPoints()
  ProcessModel(dt)
  PrioriEstimate()
--  print(state:t())
end

local times = 0
function PrioriEstimate()
  -- Generate priori estimate state and covariance
  -- priori state = mean(Y)
  state:copy(yMean)

  print('priori estimate '..times)
  times = times + 1
  local PPriori = torch.DoubleTensor(12, 12):fill(0)
  for i = 1, 2 * ns do
    local Ycol = Y:narrow(2, i, 1)
    local WDiff = torch.DoubleTensor(12, 1):fill(0)
    -- Pos & Vel
    WDiff:narrow(1, 1, 6):copy(Ycol:narrow(1, 1, 6))
    WDiff:narrow(1, 1, 6):add(-yMean:narrow(1, 1, 6))
    -- Angular Vel
    WDiff:narrow(1, 9, 3):copy(Ycol:narrow(1, 11, 3))
    WDiff:narrow(1, 9, 3):add(-yMean:narrow(1, 11, 3))
    -- Rotation
    WDiff:narrow(1, 7, 3):copy(e:narrow(2, i, 1))
    PPriori:add(WDiff * WDiff:t())
  end
  PPriori:div(2.0 * ns)
  P:copy(PPriori)
end

function ProcessModel(dt)
  -- Process Model Update and generate y

  local F = torch.DoubleTensor({{1,0,0,dt,0,0}, {0,1,0,0,dt,0}, {0,0,1,0,0,dt},
                          {0,0,0,1,0,0}, {0,0,0,0,1,0}, {0,0,0,0,0,1}})
  local G = torch.DoubleTensor({{dt^2/2,0,0}, {0,dt^2/2,0}, {0,0,dt^2/2},
                          {dt,0,0}, {0,dt,0}, {0,0,dt}})
  -- Y
  for i = 1, 2 * ns do
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
 -- Y mean
  yMean:copy(torch.mean(Y, 2))
  yMeanQ, e = QuaternionMean(Y:narrow(1, 7, 4), state:narrow(1, 7, 4))
  yMean:narrow(1, 7, 4):copy(yMeanQ)
end



function KalmanGainUpdate(Z, zMean, v, R)
  -- Pzz, Pvv
  local Pzz = torch.DoubleTensor(zMean:size(1), zMean:size(1)):fill(0)
  for i = 1, 2 * ns do
    local Zcol = Z:narrow(2, i, 1)
    local ZDiff = torch.DoubleTensor(zMean:size(1), 1):fill(0)
    ZDiff:copy(Zcol)
    ZDiff:add(-zMean)

    Pzz:add(ZDiff * ZDiff:t())
  end
  Pzz:div(2 * ns)
  local Pvv = Pzz + R

  -- Pxz
  local Pxz = torch.DoubleTensor(12, zMean:size(1)):fill(0)
  for i = 1, 2 * ns do
    local Ycol = Y:narrow(2, i, 1)
    local WDiff = torch.DoubleTensor(12, 1):fill(0)
    -- Pos & Vel
    WDiff:narrow(1, 1, 6):copy(Ycol:narrow(1, 1, 6))
    WDiff:narrow(1, 1, 6):add(-yMean:narrow(1, 1, 6))
--    print(WDiff)
    -- Angular Vel
    WDiff:narrow(1, 9, 3):copy(Ycol:narrow(1, 11, 3))
    WDiff:narrow(1, 9, 3):add(-yMean:narrow(1, 11, 3))
    -- Rotation
    WDiff:narrow(1, 7, 3):copy(e:narrow(2, i, 1))
    -- Rotation
    local Yqi = Ycol:narrow(1, 7, 4)
    local YqMean = yMean:narrow(1, 7, 4)
    local YqDiff = QuaternionMul(Yqi, QInverse(YqMean))
    local Ye = Q2Vector(YqDiff)
    WDiff:narrow(1, 7, 3):copy(Ye)

    local Zcol = Z:narrow(2, i, 1)
    local ZDiff = torch.DoubleTensor(zMean:size(1), 1):fill(0)
    ZDiff:copy(Zcol)
    ZDiff:add(-zMean)

    Pxz:add(WDiff * ZDiff:t())
  end
  Pxz:div(2 * ns)
  -- K
  local K = Pxz * torch.inverse(Pvv)

  -- posterior
  local stateadd = K * v
  state:narrow(1, 1, 6):add(stateadd:narrow(1, 1, 6))
  state:narrow(1, 11, 3):add(stateadd:narrow(1, 10, 3))
  local stateqi = state:narrow(1, 7, 4)
  local stateaddqi = Vector2Q(stateadd:narrow(1, 7, 3))
  state:narrow(1, 7, 4):copy(QuaternionMul(stateqi, stateaddqi))
  P = P - K * Pvv * K:t()
  print(state)
  print(P)
end

function measurementGravityUpdate()
  if not gravityInit then return end
  local gv = torch.DoubleTensor({0,0, gravity * g})
  local gq = Vector2Q(gv)
  local Z = torch.DoubleTensor(3, 2 * ns):fill(0)
  for i = 1, 2 * ns do
    local Zcol = Z:narrow(2, i, 1)
    local Chicol = Chi:narrow(2, i , 1)
    local qk = Chicol:narrow(1, 7, 4)
    Zcol:copy(Q2Vector(QuaternionMul(QuaternionMul(qk, gq), QInverse(qk))))
  end

  local zMean = torch.mean(Z, 2)

  local v = torch.DoubleTensor(3, 1):copy(gacc)
  v:add(-zMean)

  local R = torch.DoubleTensor(3, 3):fill(0)
  R:copy(qCovR)

  KalmanGainUpdate(Z, zMean, v, R)
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
  local Z = torch.DoubleTensor(3, 2 * ns):fill(0)
  for i = 1, 2 * ns do
    local Zcol = Z:narrow(2, i, 1)
    local Chicol = Chi:narrow(2, i , 1)
    Zcol:copy(Chicol:narrow(1, 1, 3))
  end
  local zMean = torch.mean(Z, 2)
  local zk = torch.DoubleTensor(3, 1):copy(gpspos)
  local v = zk - zMean

  local R = torch.DoubleTensor(3, 3):fill(0)
  R:copy(posCovR)

  KalmanGainUpdate(Z, zMean, v, R)

end

function measurementMagUpdate()
end

function measurementRotUpdate(tstep, imu)
  local Z = torch.DoubleTensor(3, 2 * ns):fill(0)
  for i = 1, 2 * ns do
    local Zcol = Z:narrow(2, i, 1)
    local Chicol = Chi:narrow(2, i , 1)
    Zcol:copy(Chicol:narrow(1, 11, 3))
  end
  local zMean = torch.mean(Z, 2)

  local v = torch.DoubleTensor(3, 1):copy(gyro)
  v:add(-zMean)
  local R = torch.DoubleTensor(3, 3):fill(0)
  R:copy(omegaCovR)

  KalmanGainUpdate(Z, zMean, v, R)

end

--local q = torch.DoubleTensor(4):fill(0)

--for i = 1, #dataset do
for i = 1, #dataset do
--for i = 300, 20000 do
--for i = 300, 491 do
--for i = 300, 496 do
--for i = 300, 696 do
  if dataset[i].type == 'imu' then
    processUpdate(dataset[i].timstamp, dataset[i])
    measurementGravityUpdate()
    measurementRotUpdate(dataset[i].timstamp, dataset[i])
  elseif dataset[i].type == 'gps' then
    measurementGPSUpdate(dataset[i].timstamp, dataset[i])
  elseif dataset[i].type == 'mag' then
--    measurementMagUpdate(dataset[i].timstamp, dataset[i])
  end
end

print('done')
