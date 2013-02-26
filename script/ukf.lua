require 'include'
require 'common'
require 'gpscommon'
require 'poseUtils'
require 'torch-load'
torch.setdefaulttensortype('torch.DoubleTensor')

require 'calibrateMag'

require 'ucm'

local util = require 'util'
local geo = require 'GeographicLib'
--
-- state init Posterior state
state = torch.Tensor(10, 1):fill(0) -- x, y, z, vx, vy, vz, q0, q1, q2, q3
state[7] = 1

-- state Cov, Posterior
P = torch.Tensor(9, 9):fill(0) -- estimate error covariance
posCov = torch.eye(3, 3):mul(0.005^2)
velCov = torch.eye(3, 3):mul(0.01^2)
qCov   = torch.eye(3, 3):mul((1 * math.pi / 180)^2)
P:narrow(1, 1, 3):narrow(2, 1, 3):copy(posCov)
P:narrow(1, 4, 3):narrow(2, 4, 3):copy(velCov)
P:narrow(1, 7, 3):narrow(2, 7, 3):copy(qCov)

Q = torch.Tensor(9, 9):fill(0) -- process noise covariance
posCov = torch.eye(3, 3):mul(0.005^2)
velCov = torch.eye(3, 3):mul(0.01^2)
qCov   = torch.eye(3, 3):mul((0.1 * math.pi / 180)^2)
Q:narrow(1, 1, 3):narrow(2, 1, 3):copy(posCov)
Q:narrow(1, 4, 3):narrow(2, 4, 3):copy(velCov)
Q:narrow(1, 7, 3):narrow(2, 7, 3):copy(qCov)

--R = torch.Tensor(12, 12):fill(0) -- measurement noise covariance
posCovR = torch.eye(3, 3):mul(0.5^2)
velCovR = torch.eye(3, 3):mul(0.1^2)
qCovRG  = torch.eye(3, 3):mul((0.01)^2)
qCovRM  = torch.eye(3, 3):mul((20 * math.pi / 180)^2)

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
trpy = torch.Tensor(3, 1):fill(0)
g = torch.Tensor(3, 1):fill(0)
gInitCount = 0
gInitCountMax = 100

processInit = false
gravityInit = false
gpsInit = true
magInit = false
gravity = 9.80
imuTstep = 0

counter = 0

function imuCorrent(imu)
  local ac = torch.Tensor(3, 1):fill(0)
  ac[1] = -accBiasX
  ac[2] = -accBiasY
  ac[3] = -accBiasZ

  ac[1] = ac[1] - imu.ax
  ac[2] = ac[2] + imu.ay
  ac[3] = ac[3] - imu.az
  local gyr = torch.Tensor(3, 1):fill(0)
  gyr[1] = -imu.wr
  gyr[2] = imu.wp
  gyr[3] = -imu.wy

  return ac, gyr
end

function accTiltCompensate(acc)
  -- need -180 ~ 180
  local roll = math.atan2(acc[2][1], acc[3][1])
  -- need -90 ~ 90
  local tanPitch = -acc[1][1] / (acc[2][1]*math.sin(roll)+acc[3][1]*math.cos(roll))
  local pitch = math.atan(tanPitch)

  local Ry = rotY(pitch)
  local Rx = rotX(roll)
  local _acc = Ry * Rx * acc
  return _acc
end

function processUpdate(tstep, imu)
--  print(imu.ax, imu.ay, imu.az)
  rawacc, gyro = imuCorrent(imu)
--  print 'tilt compensate'
--  print(accTiltCompensate(rawacc))
  trpy[1] = imu.r
  trpy[2] = imu.p
  trpy[3] = imu.y

  gacc = rawacc

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

  if gpsInit == false then return end

  -- substract gravity from z axis and convert from g to m/s^2
  acc:copy(gacc - g)
  acc = acc * gravity
  GenerateSigmaPoints()
  ProcessModel(dt)
  PrioriEstimate()
end

function GenerateSigmaPoints()
  -- Sigma points
  local W = cholesky((P+Q):mul(math.sqrt(2*ns)))
  local q = state:narrow(1, 7, 4)
  for i = 1, ns  do
    -- Sigma points for pos and vel
    Chi:sub(1,6,i,i):copy(state:sub(1,6) + W:sub(1,6,i,i))
    Chi:sub(1,6,i+ns,i+ns):copy(state:sub(1,6) - W:sub(1,6,i,i))

    -- Sigma points for Quaternion
    local qW = Vector2Quat(W:narrow(2, i, 1):narrow(1, 7, 3))
    Chi:narrow(2, i, 1):narrow(1, 7, 4):copy(QuatMul(q, qW))
    qW = Vector2Quat(-W:narrow(2, i, 1):narrow(1, 7, 3))
    Chi:narrow(2, i + ns, 1):narrow(1, 7, 4):copy(QuatMul(q, qW))
  end
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
    local YqDiff = QuatMul(Ycol:narrow(1, 7, 4), QuatInv(yMean:narrow(1, 7, 4)))
    WDiff:narrow(1, 7, 3):copy(Quat2Vector(YqDiff))
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
    local dq = Vector2Quat(gyro, dt)
    Ycol:narrow(1, 7, 4):copy(QuatMul(q,dq))
    --Ycol:narrow(1, 7, 4):copy(q)
  end
 -- Y mean
  yMean:copy(torch.mean(Y, 2))
  yMeanQ, e = QuatMean(Y:narrow(1, 7, 4), state:narrow(1, 7, 4))
  print("yMeanQ")
  print(yMeanQ)
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
    local YqDiff = QuatMul(Ycol:narrow(1, 7, 4), QuatInv(yMean:narrow(1, 7, 4)))
    WDiff:narrow(1, 7, 3):copy(Quat2Vector(YqDiff))

    local ZDiff = Z:narrow(2, i, 1) - zMean
    Pxz:add(WDiff * ZDiff:t())
    Pzz:add(ZDiff * ZDiff:t())
  end
  Pxz:div(2 * ns)
  Pzz:div(2 * ns)
--  print('pzz')
--  print(Pzz)
  local Pvv = Pzz + R

  -- K
  local K = Pxz * torch.inverse(Pvv)
--  print(K:narrow(1, 7, 3))

  -- posterior
  local stateadd = K * v
  state:narrow(1, 1, 6):add(stateadd:narrow(1, 1, 6))
  local stateqi = state:narrow(1, 7, 4)
  local stateaddqi = Vector2Quat(stateadd:narrow(1, 7, 3))
  state:narrow(1, 7, 4):copy(QuatMul(stateqi, stateaddqi))
  P = P - K * Pvv * K:t()
end

function measurementGravityUpdate()
  if not gravityInit then return end
--  print('gravity measure')
  local gq = torch.Tensor({0,0,0,1})
  local Z = torch.Tensor(3, 2 * ns):fill(0)
  for i = 1, 2 * ns do
    local Zcol = Z:narrow(2, i, 1)
    local Chicol = Chi:narrow(2, i , 1)
    local qk = Chicol:narrow(1, 7, 4)
    Zcol:copy(QuatMul(QuatMul(qk, gq), QuatInv(qk)):narrow(1, 2, 3))
  end
--  print('Z')
--  print(Z)
  local zMean = torch.mean(Z, 2)
  local v = rawacc - zMean
  print(v)
  local R = qCovRG
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
  gpspos[1] = -gpspos[1]
  gpspos[2] = -gpspos[2]
  local Z = torch.Tensor(3, 2 * ns):fill(0)
  for i = 1, 2 * ns do
    local Zcol = Z:narrow(2, i, 1)
    local Chicol = Chi:narrow(2, i , 1)
    Zcol:copy(Chicol:narrow(1, 1, 3))
  end
  local zMean = torch.mean(Z, 2)

  -- reset Z with zMean since no measurement here
  gpspos[3] = zMean[3]
  local v = gpspos - zMean

  local R = posCovR
  KalmanGainUpdate(Z, zMean, v, R)

end

firstmat = false
magbase = torch.DoubleTensor(3):fill(0)
function measurementMagUpdate(mag)
  -- mag and imu coordinate x, y reverse
  local rawmag = torch.DoubleTensor({mag.y, mag.x, -mag.z})
  -- calibrated & tilt compensated heading 
  local heading, Bf = magTiltCompensate(rawmag, rawacc)
  local Bc = magCalibrated(rawmag) -- calibrated raw B
  -- Normalize the raw measurement
  Bc:div(Bc:norm())

  -- set init orientation
  if not firstmat then
  --  print(heading)
    magbase = mvalue
    magInit = true
    firstmat = true
   -- error()
  end

  if not gravityInit then return end
  local mq = torch.DoubleTensor({0, 1, 0, 0})
  local Z = torch.Tensor(3, 2 * ns):fill(0)
  for i = 1, 2 * ns do
    local Zcol = Z:narrow(2, i, 1)
    local Chicol = Chi:narrow(2, i , 1)
    local qk = Chicol:narrow(1, 7, 4)
    Zcol:copy(QuatMul(QuatMul(qk, mq), QuatInv(qk)):narrow(1, 2, 3))
  end
  local zMean = torch.mean(Z, 2)
  local v = Bc - zMean
  local R = qCovRM
  KalmanGainUpdate(Z, zMean, v, R)
end


--local datasetpath = '../data/010213180247/'
--local datasetpath = '../data/'
local datasetpath = '../simulation/'
--local datasetpath = '../'
local dataset = loadData(datasetpath, 'logall')
--local dataset = loadData(datasetpath, 'imuPruned')
--local dataset = loadData(datasetpath, 'imuPruned', 10000)
--local dataset = loadData(datasetpath, 'imugpsmag', 20000)
--local dataset = loadData(datasetpath, 'imugpsmag')
--local dataset = loadData(datasetpath, 'imuPruned')


for i = 1, #dataset do
  if dataset[i].type == 'imu' then
    processUpdate(dataset[i].timestamp, dataset[i])
--    measurementGravityUpdate()
  elseif dataset[i].type == 'gps' then
--    measurementGPSUpdate(dataset[i].timestamp, dataset[i])
  elseif dataset[i].type == 'mag' then
--    measurementMagUpdate(dataset[i])
  end

  if gravityInit then
--    print('acc')
--    print(rawacc)
--    print('gy')
--    print(gyro)
    local Q = state:narrow(1, 7, 4)
    local rpy = Quat2rpy(Q)
    counter = counter + 1 
  --  rpy[1] = correctRange(rpy[1])
  --  rpy[2] = correctRange(rpy[2])
  --  rpy[3] = correctRange(rpy[3])
  
    v = vector.new({rpy[1], rpy[2], rpy[3]})
  --  print(rpy:mul(180 / math.pi))
    v1 = vector.new({trpy[1][1], trpy[2][1], trpy[3][1]})
    ucm.set_ukf_timestamp(dataset[i].timestamp)
    ucm.set_ukf_counter(counter)
    ucm.set_ukf_rpy(v)
    ucm.set_ukf_trpy(v1)
  --  print(state:narrow(1, 1, 6))
  end
end

print('done')
