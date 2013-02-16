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
--
----imuPruned = pruneTUC(dataset)
--
----saveData(imuPruned, 'imuPruned')
--
state = {}
state = torch.DoubleTensor(13):fill(0) -- x, y, z, q0, q1, q2, q3, vx, vy, vz, wx, wy, wz
pos = state:narrow(1, 1, 3)
q = state:narrow(1, 4, 4)
q[1] = 1
linearVel = state:narrow(1, 8, 3)
angularVel = state:narrow(1, 11, 3)

-- Geo Init
local firstlat = true
local basepos = {0.0, 0.0, 0.0}
local relativePosX = {}
local relativePosY = {} 
local relativeCount = 0

-- imu init
local imuax = {}
local imuay = {}
local imuaz = {}
local imucount = 0

----local q = torch.DoubleTensor(4):fill(0)
local dq = torch.DoubleTensor(4):fill(0)
local rpy = torch.DoubleTensor(3):fill(0)
local rpy1 = torch.DoubleTensor(3):fill(0)
local lasetstep = dataset[1].timstamp
for i = 2, #dataset - 1 do
--for i = 2, 1000 do
  if dataset[i].type == 'imu' then
    angularVel[1] = dataset[i].wr
    angularVel[2] = dataset[i].wp
    angularVel[3] = dataset[i].wy
    -- Rotate pi on X axes
    acc = torch.mv(rotX(math.pi), 
              torch.DoubleTensor({dataset[i].ax, dataset[i].ay, dataset[i].az}))
    local dt = dataset[i].timstamp - lasetstep
    lasetstep = dataset[i].timstamp
    if angularVel:norm() ~= 0 and dt ~= 0 then 
      -- update orientation
      acc[3] = acc[3] - 1
      acc:mul(9.8)
  --    print(acc)
  --    rpy = rpy + torch.cmul(angularVel, torch.ones(3):mul(dt))
  --    R = rpy2R(rpy)
  --    acc1 = R * acc
  --    print(acc1)
  --    print(acc1:norm())
  --    print(R)
  --    print(angularVel)
  --    print(rpy)
  
      dAngle = angularVel:norm() * dt
      dAxis = angularVel:div(angularVel:norm()) 
      dq[1] = math.cos(dAngle / 2)
      dq[{{2, 4}}] = dAxis * math.sin(dAngle / 2)
      q:copy(QuaternionMul(q, dq))
      
 --     print(acc[1], acc[2], acc[3])
  --    vel = torch.DoubleTensor({0.5, 0.6, 0.7})
      pos = pos + torch.mv(torch.diag(torch.ones(3)):mul(dt), linearVel) 
                + acc:clone():mul(dt^2*0.5)
      linearVel = linearVel + acc:clone():mul(dt)
      st = {pos[1], pos[2], pos[3], linearVel[1], linearVel[2], linearVel[3]}
      savedata = serialization.serialize(st)    
--      print(savedata)
  --    print(linearVel)
  --    pos[1] = pos[1] + linearVel[1] * dt + 0.5 * acc[1] * dt ^ 2
  --    pos[2] = pos[2] + linearVel[2] * dt + 0.5 * acc[2] * dt ^ 2
  --    pos[3] = pos[3] + linearVel[3] * dt + 0.5 * acc[3] * dt ^ 2
  --    linearVel[1] = linearVel[1] + dt * acc[1]
  --    linearVel[2] = linearVel[2] + dt * acc[2]
  --    linearVel[3] = linearVel[3] + dt * acc[3] 
    end
  elseif dataset[i].type == 'gps' then
    if dataset[i].latitude and dataset[i].latitude ~= '' then
      lat, lnt = nmea2degree(dataset[i].latitude, dataset[i].northsouth, 
                              dataset[i].longtitude, dataset[i].eastwest)
      gpspos = geo.Forward(lat, lnt, 6)
      if firstlat then
        basepos = gpspos
        firstlat = false
      else
        relativeCount = relativeCount + 1
        relativePosX[relativeCount] = gpspos.x - basepos.x
        relativePosY[relativeCount] = gpspos.y - basepos.y
        print(relativePosX[relativeCount], relativePosY[relativeCount])
      end
    end

--    util.ptable(dataset[i])
  end
end

--rpy = torch.DoubleTensor({math.pi/5, math.pi/3, math.pi/6})
--R = rpy2R(rpy)
--print(R)
--q:copy(R2Quaternion(R))
--R = torch.DoubleTensor({{0.5, 0.6, 0},{0.3, 0.7, 0},{0, 0, 1}})
--print(q)
--R1 = Quaternion2R(q)
--print(R1)
--print(q:norm())

q1 = torch.DoubleTensor({-0.2852, -0.1770, -0.6088, 0.7188})
q2 = torch.DoubleTensor({1, -0.0020, 0.0008, 0.0010})
q3 = QuaternionMul(q1, q2)
--print(q3)

--local gravity = 9.81


--print(rotX(math.pi/3))
--print(rotY(math.pi/3))
--print(rotZ(math.pi/3))
x = torch.DoubleTensor({-0.0020, 0.0008, 0.0010})
y = torch.cmul(x, torch.ones(3):mul(0.0002))
--print(y)
