require 'include'
require 'common'
require 'gpscommon'
require 'poseUtils'
require 'torch-load'
torch.setdefaulttensortype('torch.DoubleTensor')

local serialization = require 'serialization'
local util = require 'util'
local geo = require 'GeographicLib'

local datasetpath = '../data/010213180247/'
--local datasetpath = '../data/'
--local dataset = loadData(datasetpath, 'log')
--local dataset = loadData(datasetpath, 'imuPruned')
--local dataset = loadData(datasetpath, 'imuPruned', 10000)
local dataset = loadData(datasetpath, 'imugps')
--local dataset = loadData(datasetpath, 'imuPruned')

-- state init Posterior state
state = torch.Tensor(10, 1):fill(0) -- x, y, z, vx, vy, vz, q0, q1, q2, q3
state[7] = 1

-- state Cov, Posterior
P = torch.Tensor(9, 9):fill(0) -- estimate error covariance
posCov = torch.eye(3, 3):mul(0.005^2)
velCov = torch.eye(3, 3):mul(0.01^2)
qCov   = torch.eye(3, 3):mul((10 * math.pi / 180)^2)
P:narrow(1, 1, 3):narrow(2, 1, 3):copy(posCov)
P:narrow(1, 4, 3):narrow(2, 4, 3):copy(velCov)
P:narrow(1, 7, 3):narrow(2, 7, 3):copy(qCov)

Q = torch.Tensor(9, 9):fill(0) -- process noise covariance
posCov = torch.eye(3, 3):mul(0.005^2)
velCov = torch.eye(3, 3):mul(0.01^2)
qCov   = torch.eye(3, 3):mul((10 * math.pi / 180)^2)
Q:narrow(1, 1, 3):narrow(2, 1, 3):copy(posCov)
Q:narrow(1, 4, 3):narrow(2, 4, 3):copy(velCov)
Q:narrow(1, 7, 3):narrow(2, 7, 3):copy(qCov)

--R = torch.Tensor(12, 12):fill(0) -- measurement noise covariance
posCovR = torch.eye(3, 3):mul(2^2)
velCovR = torch.eye(3, 3):mul(0.1^2)
qCovR   = torch.eye(3, 3):mul((10 * math.pi / 180)^2)

ns = 9
Chi = torch.Tensor(state:size(1), 2 * ns):fill(0)
ChiMean = torch.Tensor(10, 1):fill(0)
e = torch.Tensor(3, 2 * ns + 1):fill(0)
Y = torch.Tensor(state:size(1), 2 * ns):fill(0)
yMean = torch.Tensor(10, 1):fill(0)
e = torch.Tensor(3, 2 * ns):fill(0)

-- Imu Init
accBiasX = -0.03
accBiasY = 0
accBiasZ = 0

acc = torch.Tensor(3, 1):fill(0)
gacc = torch.Tensor(3, 1):fill(0)
rawacc = torch.Tensor(3, 1):fill(0)
gyro = torch.Tensor(3, 1):fill(0)

g = torch.Tensor(3, 1):fill(0)
gInitCount = 0
gInitCountMax = 100

processInit = false
gravityInit = false
gpsInit = false
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

    -- Sigma points for Quaternion
    local qW = Vector2Q(Wcol:narrow(1, 7, 3))
    local negqW = Vector2Q(-Wcol:narrow(1, 7, 3))
    posChi:narrow(1, 7, 4):copy(QuaternionMul(q, qW))
    negChi:narrow(1, 7, 4):copy(QuaternionMul(q, negqW))
  end
end

function processUpdate(tstep, imu)
  if gpsInit == false then return end
  rawacc[1] = imu.ax - accBiasX
  rawacc[2] = imu.ay - accBiasY
  rawacc[3] = imu.az - accBiasZ
  local Rconst = rpy2R(torch.Tensor({math.pi, 0, 0}))
  local R = Quaternion2R(state:narrow(1, 7, 4))
  gacc = Rconst * R:t() * rawacc

  if processInit == false then 
    processInit = true
    imuTstep = tstep
    return
  end

  local dt = tstep - imuTstep
  if dt == 0 then return end 
  imuTstep = tstep

  if not gravityInit then
    g:add(gacc)
    gInitCount = gInitCount + 1
    if gInitCount >= gInitCountMax then
      print('Initiate Gravity')
      g = g:div(gInitCount)
      gravityInit = true
    else
      return
    end
  end

  -- substract gravity from z axis and convert from g to m/s^2
  acc:copy(gacc)
  acc:add(-g)
  acc = acc * gravity
  gyro[1] = imu.wr
  gyro[2] = imu.wy
  gyro[3] = imu.wp

  GenerateSigmaPoints()
  ProcessModel(dt)
  PrioriEstimate()
end

function PrioriEstimate()
  -- Generate priori estimate state and covariance
  -- priori state = mean(Y)
  state:copy(yMean)

  local PPriori = torch.Tensor(9, 9):fill(0)
  for i = 1, 2 * ns do
    local Ycol = Y:narrow(2, i, 1)
    local WDiff = torch.Tensor(9, 1):fill(0)
    -- Pos & Vel
    WDiff:narrow(1, 1, 6):copy(Ycol:narrow(1, 1, 6) - yMean:narrow(1, 1, 6))
    -- Rotation
    WDiff:narrow(1, 7, 3):copy(e:narrow(2, i, 1))
    PPriori:add(WDiff * WDiff:t())
  end
  PPriori:div(2.0 * ns)
  P:copy(PPriori)
end

function ProcessModel(dt)
  -- Process Model Update and generate y
  local F = torch.Tensor({{1,0,0,dt,0,0}, {0,1,0,0,dt,0}, {0,0,1,0,0,dt},
                          {0,0,0,1,0,0}, {0,0,0,0,1,0}, {0,0,0,0,0,1}})
  local G = torch.Tensor({{dt^2/2,0,0}, {0,dt^2/2,0}, {0,0,dt^2/2},
                          {dt,0,0}, {0,dt,0}, {0,0,dt}})
  -- Y
  for i = 1, 2 * ns do
    local Chicol = Chi:narrow(2, i, 1)
    local Ycol = Y:narrow(2, i, 1)
    local posvel = Ycol:narrow(1, 1, 6)

    posvel:copy(F * Chicol:narrow(1, 1, 6) + G * acc)
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
  -- Pxz Pzz Pvv
  local Pxz = torch.Tensor(9, zMean:size(1)):fill(0)
  local Pzz = torch.Tensor(zMean:size(1), zMean:size(1)):fill(0)
  for i = 1, 2 * ns do
    local Ycol = Y:narrow(2, i, 1)
    local WDiff = torch.Tensor(9, 1):fill(0)
    -- Pos & Vel
    WDiff:narrow(1, 1, 6):copy(Ycol:narrow(1, 1, 6) - yMean:narrow(1, 1, 6))
    -- Rotation
    local YqDiff = QuaternionMul(Ycol:narrow(1, 7, 4), QInverse(yMean:narrow(1, 7, 4)))
    WDiff:narrow(1, 7, 3):copy(Q2Vector(YqDiff))

    local ZDiff = Z:narrow(2, i, 1) - zMean
    Pxz:add(WDiff * ZDiff:t())
    Pzz:add(ZDiff * ZDiff:t())
  end
  Pxz:div(2 * ns)
  Pzz:div(2 * ns)
  local Pvv = Pzz + R

  -- K
  local K = Pxz * torch.inverse(Pvv)

  -- posterior
  local stateadd = K * v
  state:narrow(1, 1, 6):add(stateadd:narrow(1, 1, 6))
  local stateqi = state:narrow(1, 7, 4)
  local stateaddqi = Vector2Q(stateadd:narrow(1, 7, 3))
  state:narrow(1, 7, 4):copy(QuaternionMul(stateqi, stateaddqi))
  P = P - K * Pvv * K:t()
--  print(state)
--  print(gyro:t())
--  print(P)
end

function measurementGravityUpdate()
  if not gravityInit then return end
  local gq = torch.Tensor({0,0,0,1})
  local Z = torch.Tensor(3, 2 * ns):fill(0)
  for i = 1, 2 * ns do
    local Zcol = Z:narrow(2, i, 1)
    local Chicol = Chi:narrow(2, i , 1)
    local qk = Chicol:narrow(1, 7, 4)
    Zcol:copy(QuaternionMul(qk, gq):narrow(1, 2, 3))
  end
  local zMean = torch.mean(Z, 2)
  local v = rawacc - zMean
  local R = qCovR
  KalmanGainUpdate(Z, zMean, v, R)
end

-- Geo Init
firstlat = true
local basepos = {0.0, 0.0, 0.0}
function measurementGPSUpdate(tstep, gps)
  if gps.latitude == nil or gps.latitude == '' then return end
  
  local lat, lnt = nmea2degree(gps.latitude, gps.northsouth, 
                                gps.longtitude, gps.eastwest)
  local gpsposAb = geo.Forward(lat, lnt, 6)

  if firstlat then
      basepos = gpsposAb
      firstlat = false
      gpsInit = true
  end

  local gpspos = torch.Tensor({gpsposAb.x - basepos.x, 
                                      gpsposAb.y - basepos.y, 0})
  local Z = torch.Tensor(3, 2 * ns):fill(0)
  for i = 1, 2 * ns do
    local Zcol = Z:narrow(2, i, 1)
    local Chicol = Chi:narrow(2, i , 1)
    Zcol:copy(Chicol:narrow(1, 1, 3))
  end
  local zMean = torch.mean(Z, 2)
  local v = gpspos - zMean
  print(v)

  local R = posCovR
  KalmanGainUpdate(Z, zMean, v, R)

end

function measurementMagUpdate()
end

--for i = 100, #dataset do
for i = 1, #dataset do
--for i = 1, 8800 do
--for i = 1, 200 do
--for i = 1, 500 do
--for i = 300, 421 do
--for i = 100, 505 do
--for i = 300, 696 do
--for i = 100, 3000 do
  if dataset[i].type == 'imu' then
--    util.ptable(dataset[i])
    processUpdate(dataset[i].timstamp, dataset[i])
    measurementGravityUpdate()
  elseif dataset[i].type == 'gps' then
    measurementGPSUpdate(dataset[i].timstamp, dataset[i])
  elseif dataset[i].type == 'mag' then
--    measurementMagUpdate(dataset[i].timstamp, dataset[i])
  end
end

print('done')
