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

processInit = false
imuTstep = 0
function processUpdate(tstep, acc)
  if processInit == false then 
--    print('init')
    processInit = true
    imuTstep = tstep
    return
  end
  
  local dt = tstep - imuTstep
  if dt == 0 then return end 
  imuTstep = tstep

  acc[3] = acc[3] - 1
  acc:mul(9.8)
  F = torch.DoubleTensor({{1,0,0,dt,0,0}, {0,1,0,0,dt,0}, {0,0,1,0,0,dt},
                          {0,0,0,1,0,0}, {0,0,0,0,1,0}, {0,0,0,0,0,1}})
  G = torch.DoubleTensor({{dt^2/2,0,0}, {0,dt^2/2,0}, {0,0,dt^2/2},
                          {dt,0,0}, {0,dt,0}, {0,0,dt}})
  state = F * state + G * acc
  Q = G * G:t() * 0.01 * 0.01
  P = F * P * F:t() + Q
end

function measurementGPSUpdate(GPSpos)
  H = torch.DoubleTensor({{1,0,0,0,0,0}, {0,1,0,0,0,0}, {0,0,1,0,0,0}})
  y = GPSpos - H * state
  S = H * P * H:t() + R
  K = P * H:t() * torch.inverse(S)
  state = state + K * y
  P = (torch.ones(6,6) - K * H) * P
end

state = {}
-- x, y, z, vx, vy, vz
state = torch.DoubleTensor(6):fill(0) 
P = torch.eye(6):mul(1000)
R = torch.eye(3):mul(1000)

-- Geo Init
local firstlat = true
local basepos = {0.0, 0.0, 0.0}


----local q = torch.DoubleTensor(4):fill(0)
local lasetstep = dataset[1].timstamp
for i = 1, #dataset do
--for i = 1, 20 do
  if dataset[i].type == 'imu' then
    acc = torch.DoubleTensor({dataset[i].ax - accBiasX, dataset[i].ay - accBiasY, dataset[i].az - accBiasZ})
    -- Rotate pi on X axes
    acc = torch.mv(rotX(math.pi), acc)
    print(acc[1], acc[2], acc[3])
--    processUpdate(dataset[i].timstamp, acc)
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
--        measurementGPSUpdate(gpsposition)
      end
    end

  end
end
--local gravity = 9.81
