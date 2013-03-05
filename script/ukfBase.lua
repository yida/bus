require 'include'
require 'common'
require 'torch-load'

require 'GPSUtils'
require 'poseUtils'
require 'magUtils'
require 'imuUtils'

-- state init Posterior state
state = torch.Tensor(10, 1):fill(0) -- x, y, z, vx, vy, vz, q0, q1, q2, q3
state[7] = 1

-- state Cov, Posterior
P = torch.Tensor(9, 9):fill(0) -- estimate error covariance
P:sub(1, 3, 1, 3):copy(torch.eye(3, 3):mul(0.05^2))
P:sub(4, 6, 4, 6):copy(torch.eye(3, 3):mul(0.01^2))
P:sub(7, 9, 7, 9):copy(torch.eye(3, 3):mul((10 * math.pi / 180)^2))

Q = torch.Tensor(9, 9):fill(0) -- process noise covariance
Q:sub(1, 3, 1, 3):copy(torch.eye(3, 3):mul(0.05^2))
Q:sub(4, 6, 4, 6):copy(torch.eye(3, 3):mul(0.01^2))
Q:sub(7, 9, 7, 9):copy(torch.eye(3, 3):mul((0.1 * math.pi / 180)^2))

--R = torch.Tensor(12, 12):fill(0) -- measurement noise covariance
posCovR = torch.eye(3, 3):mul(0.5^2)
velCovR = torch.eye(3, 3):mul(0.1^2)
qCovRG  = torch.eye(3, 3):mul((1 * math.pi / 180)^2)
qCovRM  = torch.eye(3, 3):mul((1)^2)

ns = 9
Chi = torch.Tensor(10, 2 * ns):fill(0)
ChiMean = torch.Tensor(10, 1):fill(0)
e = torch.Tensor(3, 2 * ns):fill(0)
Y = torch.Tensor(10, 2 * ns):fill(0)
yMean = torch.Tensor(10, 1):fill(0)

-- Imu Init
accBias = torch.Tensor({-0.03, 0, 0})

acc = torch.Tensor(3, 1):fill(0)
gacc = torch.Tensor(3, 1):fill(0)
rawacc = torch.Tensor(3, 1):fill(0)
gyro = torch.Tensor(3, 1):fill(0)
g = torch.Tensor(3, 1):fill(0)
gInitCount = 0
gInitCountMax = 100

processInit = false
imuInit = false
gpsInit = false 
magInit = false
gravity = 9.80
imuTstep = 0


function imuInitiate(step, imu)
  if not imuInit then
    g:add(gacc)
    gInitCount = gInitCount + 1
    if gInitCount >= gInitCountMax then
      g = g:div(gInitCount)
      print('Initiated Gravity')
      return true
    else
      return false
    end
  end
end

function processUpdate(tstep, imu)
  rawacc, gyro = imuCorrent(imu, accBias)
  gacc = accTiltCompensate(rawacc)
  local dtime = tstep - imuTstep
  imuTstep = tstep

  if not imuInit then
    imuInit = imuInitiate(tstep, imu)
    return false
  end

  -- substract gravity from z axis and convert from g to m/s^2
  acc:copy(gacc - g)
  acc = acc * gravity
  local res = GenerateSigmaPoints(dtime)
  if res == false then return false end
  res = ProcessModel(dtime)
  if res == false then return false end
  res = PrioriEstimate(dtime)
  if res == false then return false end

  return true
end

function GenerateSigmaPoints(dt)
  -- Sigma points
  local W = cholesky((P+Q):mul(math.sqrt(2*ns)))
  local q = state:narrow(1, 7, 4)
  for i = 1, ns do
    -- Sigma points for pos and vel
    Chi:sub(1,6,i,i):copy(state:sub(1,6) + W:sub(1,6,i,i))
    Chi:sub(1,6,i+ns,i+ns):copy(state:sub(1,6) - W:sub(1,6,i,i))

    -- Sigma points for Quaternion
    local eW = W:narrow(2, i, 1):narrow(1, 7, 3)
    local qW = Vector2Quat(eW)
    Chi:narrow(2, i, 1):narrow(1, 7, 4):copy(QuatMul(q, qW))
    qW = Vector2Quat(-eW)
    Chi:narrow(2, i + ns, 1):narrow(1, 7, 4):copy(QuatMul(q, qW))
  end
  return true
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
    Y:narrow(2, i, 1):narrow(1, 1, 6):copy(F * Chicol:narrow(1, 1, 6) + G * acc)

    local q = Chicol:narrow(1, 7, 4)
    local dq = Vector2Quat(gyro, dt)
    Y:narrow(2, i, 1):narrow(1, 7, 4):copy(QuatMul(q,dq))
  end
 -- Y mean
  yMean:copy(torch.mean(Y, 2))
  yMeanQ = QuatMean(Y:narrow(1, 7, 4), state:narrow(1, 7, 4))
  yMean:narrow(1, 7, 4):copy(yMeanQ)
  return true
end

function PrioriEstimate(dt)
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
    local YqDiff = QuatMul(Ycol:narrow(1, 7, 4), QuatInv(yMean:narrow(1, 7, 4)))
    WDiff:narrow(1, 7, 3):copy(Quat2Vector(YqDiff))
    PPriori:add(WDiff * WDiff:t())
  end
  PPriori:div(2.0 * ns)
  P:copy(PPriori)
  return true
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
    local YqDiff = QuatMul(Ycol:narrow(1, 7, 4), QuatInv(yMean:narrow(1, 7, 4)))
    WDiff:narrow(1, 7, 3):copy(Quat2Vector(YqDiff))

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
  local stateaddqi = Vector2Quat(stateadd:narrow(1, 7, 3))
  state:narrow(1, 7, 4):copy(QuatMul(stateqi, stateaddqi))
  P = P - K * Pvv * K:t()
  return true
end

function measurementGravityUpdate()
  local gq = torch.Tensor({0,0,0,1})
  local Z = torch.Tensor(3, 2 * ns):fill(0)
  for i = 1, 2 * ns do
    local Zcol = Z:narrow(2, i, 1)
    local Chicol = Chi:narrow(2, i , 1)
    local qk = Chicol:narrow(1, 7, 4)
    Zcol:copy(QuatMul(QuatMul(qk, gq), QuatInv(qk)):narrow(1, 2, 3))
  end
  local zMean = torch.mean(Z, 2)
  local v = rawacc - zMean
  local R = qCovRG
  return KalmanGainUpdate(Z, zMean, v, R)
end

-- Geo Init
function gpsInitiate(gps)
  if gps.latitude == nil or gps.longtitude == nil 
                            or gps.height == nil then
    return false
  end
  if gps.latitude == '' or gps.longtitude == '' 
                            or gps.height == '' then
    return false
  end
  local gpspos = global2metric(gps)
  -- set init pos
  state[1] = gpspos[1]
  state[2] = gpspos[2]
  state[3] = gps.height
  print('initiate GPS') 
  return true
end

firstlat = true
function measurementGPSUpdate(gps)
  if gps.latitude == nil or gps.latitude == '' then return end
  local gpspos = global2metric(gps)

  if not gpsInit then
    gpsInit = gpsInitiate(gps)
    return false
  end

  local Z = torch.Tensor(3, 2 * ns):fill(0)
  for i = 1, 2 * ns do
    local Zcol = Z:narrow(2, i, 1)
    local Chicol = Chi:narrow(2, i , 1)
    Zcol:copy(Chicol:narrow(1, 1, 3))
  end
  local zMean = torch.mean(Z, 2)

  -- reset Z with zMean since no measurement here
  local v = gpspos - zMean

  local R = posCovR
  return KalmanGainUpdate(Z, zMean, v, R)

end

function magInitiate(mag)
  -- mag and imu coordinate x, y reverse
  local rawmag = magCorrect(mag)
  -- calibrated & tilt compensated heading 
  local heading, Bf = magTiltCompensate(rawmag, rawacc)

  -- HACK here as set mag heading always as init yaw value
  local initRPY = torch.Tensor({0,0,heading}) 
  local initQ = torch.Tensor(rpy2Quat(initRPY))
  state:sub(7, 10, 1, 1):copy(initQ)
  print('initiated mag')
  return true  
end

firstmat = false
magbase = torch.DoubleTensor(3):fill(0)
function measurementMagUpdate(mag)
  -- mag and imu coordinate x, y reverse
  local rawmag = magCorrect(mag)
  -- calibrated & tilt compensated heading 
  local heading, Bf = magTiltCompensate(rawmag, rawacc)

  -- set init orientation
  if not magInit then
    magInit = magInitiate(mag)
    return false
  end

  local calibratedMag = magCalibrated(rawmag)
  -- just use the first too
  calibratedMag[3] = 0
  calibratedMag:div(calibratedMag:norm())
  
  local mq = torch.DoubleTensor({0, 1, 0, 0})
  local Z = torch.Tensor(3, 2 * ns):fill(0)
  for i = 1, 2 * ns do
    local Zcol = Z:narrow(2, i, 1)
    local Chicol = Chi:narrow(2, i , 1)
    local qk = Chicol:narrow(1, 7, 4)
    Zcol:copy(QuatMul(QuatMul(qk, mq), QuatInv(qk)):narrow(1, 2, 3))
  end
  local zMean = torch.mean(Z, 2)
  local v = calibratedMag - zMean
  local R = qCovRM
  return = KalmanGainUpdate(Z, zMean, v, R)
end
