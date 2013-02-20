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
P = torch.DoubleTensor(12, 12):fill(0) -- estimate error covariance
posCov = torch.eye(3, 3):mul(0.5^2)
P:narrow(1, 1, 3):narrow(2, 1, 3):copy(posCov)
velCov = torch.eye(3, 3):mul(0.1^2)
P:narrow(1, 4, 3):narrow(2, 4, 3):copy(velCov)
qCov   = torch.eye(3, 3):mul((10 * math.pi / 180)^2)
P:narrow(1, 7, 3):narrow(2, 7, 3):copy(qCov)
omegaCov = torch.eye(3, 3):mul(0.01^2)
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

R = torch.DoubleTensor(12, 12):fill(0) -- measurement noise covariance
posCovR = torch.eye(3, 3):mul(2^2)
velCovR = torch.eye(3, 3):mul(0.1^2)
qCovR   = torch.eye(3, 3):mul((10 * math.pi / 180)^2)
omegaCovR = torch.eye(3, 3):mul(0.01^2)
--R:narrow(1, 1, 3):narrow(2, 1, 3):copy(posCov)
--R:narrow(1, 4, 3):narrow(2, 4, 3):copy(velCov)
--R:narrow(1, 7, 3):narrow(2, 7, 3):copy(qCov)
--R:narrow(1, 10, 3):narrow(2, 10, 3):copy(omegaCov)


ns = 12
Chi = torch.DoubleTensor(state:size(1), 2 * ns):fill(0)
ChiMean = torch.DoubleTensor(13, 1):fill(0)
e = torch.DoubleTensor(3, 2 * ns + 1):fill(0)
Y = torch.DoubleTensor(state:size(1), 2 * ns):fill(0)
yMean = torch.DoubleTensor(13, 1):fill(0)
Z = torch.DoubleTensor(state:size(1), 2 * ns):fill(0)
zMean = torch.DoubleTensor(13, 1):fill(0)
v = torch.DoubleTensor(12, 1):fill(0)
Pzz = torch.eye(12):mul(1)
Pvv = torch.eye(12):mul(1)
Pxz = torch.eye(12):mul(1)
K = torch.DoubleTensor(12, 12):fill(0)
e = torch.DoubleTensor(3, 2 * ns):fill(0)

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
  ProcessModel(dt)
  PrioriEstimate()
  print(state:t())
end

local times = 0
function PrioriEstimate()
  -- Generate priori estimate state and covariance
  -- priori state = mean(Y)
  state:copy(yMean)

  print('priori estimate '..times)
  times = times + 1
--  print(Chi)
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
--    print 'fdfdf'
--    print(WDiff:t())
    PPriori:add(WDiff * WDiff:t())
--    print(PPriori)
  end
  PPriori:div(2.0 * ns)
  P:copy(PPriori)
--  print(P)
end

function ProcessModel(dt)
  -- Process Model Update and generate y

  local F = torch.DoubleTensor({{1,0,0,dt,0,0}, {0,1,0,0,dt,0}, {0,0,1,0,0,dt},
                          {0,0,0,1,0,0}, {0,0,0,0,1,0}, {0,0,0,0,0,1}})
  local G = torch.DoubleTensor({{dt^2/2,0,0}, {0,dt^2/2,0}, {0,0,dt^2/2},
                          {dt,0,0}, {0,dt,0}, {0,0,dt}})
  -- Y
  print'chi line'
  print(Chi:narrow(2, 1, 1))
  for i = 1, 2 * ns do
    local Chicol = Chi:narrow(2, i, 1)
    local Ycol = Y:narrow(2, i, 1)
    local posvel = Ycol:narrow(1, 1, 6)

    posvel:copy(F * Chicol:narrow(1, 1, 6) + G * acc)
    local omega = Ycol:narrow(1, 11, 3) 
    omega:copy(gyro)
    
    local q = Chicol:narrow(1, 7, 4)
    local dq = Vector2Q(gyro, dt)
--    local dq = torch.DoubleTensor({1,0,0,0})
    Ycol:narrow(1, 7, 4):copy(QuaternionMul(q,dq))
  end
 -- Y mean
  print 'y col'
  print(Y:narrow(2, 1, 1))
  yMean:copy(torch.mean(Y, 2))
  yMeanQ, e = QuaternionMean(Y:narrow(1, 7, 4), state:narrow(1, 7, 4))
  yMean:narrow(1, 7, 4):copy(yMeanQ)
--  print(dt)
--  print(acc)
--  print(Y)
end



function KalmanGainUpdate()
  -- Pzz, Pvv
  Pzz:fill(0)
  for i = 1, 2 * ns do
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
  Pzz:div(2 * ns)
  print(R)
  Pvv = Pzz + R

  -- Pxz
  Pxz:fill(0)
--  print(Y)
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
--    print(i)
--    print(yMean)

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
--    print(WDiff)
--    print(ZDiff)
    Pxz:add(WDiff * ZDiff:t())
  end
  Pxz:div(2 * ns)
--  print(Pxz)
  -- K
--  pdcheck(Pvv)
  K = Pxz * torch.inverse(Pvv)
--  pdcheck(Pvv)

  -- posterior
--  print(v)
  local stateadd = K * v
  state:narrow(1, 1, 6):add(stateadd:narrow(1, 1, 6))
  state:narrow(1, 11, 3):add(stateadd:narrow(1, 10, 3))
  local stateqi = state:narrow(1, 7, 4)
  local stateaddqi = Vector2Q(stateadd:narrow(1, 7, 3))
  state:narrow(1, 7, 4):copy(QuaternionMul(stateqi, stateaddqi))
--  print(state)
--  print('check P')
--  pdcheck(P)
--  print('check addon')
--  print(P)
--  pdcheck(K * Pvv * K:t())
  P = P - K * Pvv * K:t()
--  print(state)

end

function measurementGravityUpdate()
  if not gravityInit then return end
  local gv = torch.DoubleTensor({0,0, gravity * g})
  local gq = Vector2Q(gv)
  for i = 1, 2 * ns do
    local Zcol = Z:narrow(2, i, 1)
    local Chicol = Chi:narrow(2, i , 1)
    local qk = Chicol:narrow(1, 7, 4)
    Zcol:narrow(1, 7, 4):copy(QuaternionMul(QuaternionMul(qk, gq), QInverse(qk)))
  end

  zMeanQ = QuaternionMean(Z:narrow(1, 7, 4), gq)
  zMean:fill(0)
  zMean:narrow(1, 7, 4):copy(zMeanQ)

  v:fill(0)
  local gq = Vector2Q(acc)
  local zqMean = zMean:narrow(1, 7, 4)
  local vv = Q2Vector(QuaternionMul(gq, QInverse(zqMean)))
  v:narrow(1, 7, 3):copy(vv)

  R:fill(0)
  R:narrow(1, 7, 3):narrow(2, 7, 3):copy(qCovR)

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
  for i = 1, 2 * ns do
    local Zcol = Z:narrow(2, i, 1)
    local Chicol = Chi:narrow(2, i , 1)
    Zcol:narrow(1, 1, 3):copy(Chicol:narrow(1, 1, 3))
  end
  zMean = torch.mean(Z, 2)
  local zk = torch.DoubleTensor(13):fill(0)
  zk:narrow(1, 1, 3):copy(gpspos)
  v = zk - zMean

  R:fill(0)
  R:narrow(1, 1, 3):narrow(2, 1, 3):copy(posCovR)

  KalmanGainUpdate()

end

function measurementMagUpdate()
end

function measurementRotUpdate(tstep, imu)
  Z:fill(0)
  for i = 1, 2 * ns do
    local Zcol = Z:narrow(2, i, 1)
    local Chicol = Chi:narrow(2, i , 1)
    Zcol:narrow(1, 11, 3):copy(Chicol:narrow(1, 11, 3))
  end
  zMean = torch.mean(Z, 2)

  v:fill(0)
  v[10]:copy(-zMean[11]):add(imu.wr) 
  v[11]:copy(-zMean[12]):add(imu.wp)
  v[12]:copy(-zMean[13]):add(imu.wy)
--  v:narrow(1, 10, 3):copy()
  R:fill(0)
  R:narrow(1, 7, 3):narrow(2, 7, 3):copy(qCovR)

  KalmanGainUpdate()

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
--    measurementRotUpdate(dataset[i].timstamp, dataset[i])
  elseif dataset[i].type == 'gps' then
--    measurementGPSUpdate(dataset[i].timstamp, dataset[i])
  elseif dataset[i].type == 'mag' then
--    measurementMagUpdate(dataset[i].timstamp, dataset[i])
  end
end

print('done')
