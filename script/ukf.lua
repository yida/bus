require 'include'
require 'common'
require 'gpscommon'
require 'poseUtils'
require 'torch-load'

local serialization = require('serialization');
local util = require('util');
local geo = require 'GeographicLib'

local datasetpath = '../data/010213180247/'
local dataset = loadData(datasetpath, 'imugps')

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
P = torch.eye(12):mul(1000)
Q = torch.eye(12):mul(1000)

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
  
--  print(acc[1], acc[2], acc[3])
  state[11] = 2
  state[12] = 3.2
  state[13] = 4.3

  Omega = torch.sqrt((P+Q):mul(2*ns)) 
  Chi = torch.DoubleTensor(state:size(1), 2 * ns + 1):fill(0)
  Chi:narrow(2, 1, 1):copy(state)
  q = torch.DoubleTensor(4):copy(state:narrow(1, 7, 4))

  for i = 2, ns + 1  do
    OmegaCol = Omega:narrow(2, i-1, 1)
    posChi = Chi:narrow(2, i, 1):copy(state)
    negChi = Chi:narrow(2, i + ns, 1):copy(state)
    -- Sigma points for pos and vel
    posChi:narrow(1, 1, 6):add(OmegaCol:narrow(1, 1, 6))
    negChi:narrow(1, 1, 6):add(-OmegaCol:narrow(1, 1, 6))
    -- Sigma points for angular vel
    posChi:narrow(1, 11, 3):add(OmegaCol:narrow(1, 10, 3))
    negChi:narrow(1, 11, 3):add(-OmegaCol:narrow(1, 10, 3))

    -- Sigma points for Quaternion
    qOmega = Omega2Q(OmegaCol:narrow(1, 7, 3))
    negqOmega = Omega2Q(-OmegaCol:narrow(1, 7, 3))
    if qOmega ~= -1 and negqOmega ~= -1 then
      posChi:narrow(1, 7, 4):copy(QuaternionMul(q, qOmega))
      negChi:narrow(1, 7, 4):copy(QuaternionMul(q, negqOmega))
    end
  end

  
  print(Chi)

--  angularVel[1] = imuset[i].wr
--  angularVel[2] = imuset[i].wp
--  angularVel[3] = imuset[i].wy
--
--  if angularVel:norm() ~= 0 and dt ~= 0 then 
--    -- update orientation
--    dAngle = angularVel:norm() * dt
--    dAxis = angularVel:div(angularVel:norm()) 
--    dq[1] = math.cos(dAngle / 2)
--    dq[{{2, 4}}] = dAxis * math.sin(dAngle / 2)
--    q:copy(QuaternionMul(q, dq))
--    
--  end


--  acc[3] = acc[3] - 1
--  acc:mul(9.8)
--  F = torch.DoubleTensor({{1,0,0,dt,0,0}, {0,1,0,0,dt,0}, {0,0,1,0,0,dt},
--                          {0,0,0,1,0,0}, {0,0,0,0,1,0}, {0,0,0,0,0,1}})
--  G = torch.DoubleTensor({{dt^2/2,0,0}, {0,dt^2/2,0}, {0,0,dt^2/2},
--                          {dt,0,0}, {0,dt,0}, {0,0,dt}})
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
