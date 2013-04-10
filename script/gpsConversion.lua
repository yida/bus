require 'include'
require 'common'
require 'poseUtils'
require 'GPSUtils'

local mp = require 'MessagePack'

local serialization = require('serialization');

local datasetpath = '../data/150213185940.20/'
--local datasetpath = '../data/010213180247/'
--local datasetpath = '../data/010213192135/'
--local datasetpath = '../data/191212190259/'
--local datasetpath = '../data/211212164337/'
--local datasetpath = '../data/211212165622/'
local datasetpath = './'
local dataset = loadDataMP(datasetpath, 'gpsMP', _, 1)
--local dataset = loadData(datasetpath, 'gps', _, 1)
print('done loading data')

earth = Geocentric.new(Constants.WGS84_a(), Constants.WGS84_f())
coorInit = false

local counter = 0
local labelcounter = 0
local gpsLocal = {}
local dopcounter = 0
local HDOP = '3'
local VDOP = '3'
local PDOP = '3'
local satellites = 4
local height = 0
local heightInit = false
local latitude = 0
local latitudeInit = false
local longtitude = 0
local longtitudeInit = false
local tstep = 0
local datatype = ''
local coorInit = false
local nspeed = 0
local truecourse = 0

for i = 1, #dataset do
  if dataset[i].type == 'gps' then
    local positionUpdate = false
    local velocityUpdate = false
    if dataset[i].HDOP ~= nil then
      HDOP = tonumber(dataset[i].HDOP)
    end
    if dataset[i].VDOP ~= nil then
      VDOP = tonumber(dataset[i].VDOP)
    end
    if dataset[i].PDOP ~= nil then
      PDOP = tonumber(dataset[i].PDOP)
    end
    if dataset[i].satellites ~= nil then
      satellites = tonumber(dataset[i].satellites)
    end
    print(HDOP, VDOP, PDOP)

    if dataset[i].height ~= nil and dataset[i].height ~= '' then
      height = tonumber(dataset[i].height)
      heightInit = true
    end

    if dataset[i].latitude ~= nil and dataset[i].longtitude ~= nil and
       dataset[i].latitude ~= '' and dataset[i].longtitude ~= '' then
      latitudeInit = true
      longtitudeInit = true
      positionUpdate = true
      latitude, longtitude = nmea2degree(dataset[i].latitude, dataset[i].northsouth, 
                                  dataset[i].longtitude, dataset[i].eastwest)
    end

    if dataset[i].nspeed ~= nil then
      nspeed = tonumber(dataset[i].nspeed) or 0
      truecourse = tonumber(dataset[i].truecourse) or 0
--      print(dataset[i].id, nspeed, truecourse)
      velocityUpdate = true
    end

    local timestamp = dataset[i].timstamp or dataset[i].timestamp
    if timestamp ~= nil then tstep = timestamp end
    if dataset[i].type ~= nil then datatype = dataset[i].type end
    
--    print(latitude, longtitude, height)
    if coorInit == false and heightInit and latitudeInit and longtitudeInit then
--      print(latitude, longtitude, height)
      proj = LocalCartesian.new(latitude, longtitude, height, earth)
      coorInit = true
    end

    if coorInit and positionUpdate then
      ret = proj:Forward(latitude, longtitude, height)
--      print(ret.x, ret.y, ret.z, HDOP, VDOP, PDOP, latitude, longtitude) 
--      local lgps = dataset[i]
      lgps = {}
      lgps.id = dataset[i].id
      lgps.type = datatype
      lgps.timestamp = tstep
      lgps.latitude = latitude
      lgps.longtitude = longtitude
      lgps.height = height
      lgps.x = ret.x
      lgps.y = ret.y
      lgps.z = ret.z
      lgps.HDOP = HDOP
      lgps.VDOP = VDOP
      lgps.PDOP = PDOP
      lgps.satellites = satellites
      if velocityUpdate then
        lgps.nspeed = nspeed
        lgps.truecourse = truecourse or 0
      end
      gpsLocal[#gpsLocal+1] = lgps
    end
  end
end

print(#gpsLocal, dopcounter)
saveDataMP(gpsLocal, 'gpsLocalMP', './')
