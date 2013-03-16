require 'ucm'

require 'include'
require 'common'
require 'poseUtils'
require 'torch-load'
require 'GPSUtils'

local mp = require 'MessagePack'

local serialization = require('serialization');

local datasetpath = '../data/150213185940/'
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
local height = 0
local heightInit = false
local latitude = 0
local latitudeInit = false
local longtitude = 0
local longtitudeInit = false
local tstep = 0
local datatype = ''
local coorInit = false

for i = 1, #dataset do
  if dataset[i].type == 'gps' then
    local positionUpdate = false
    if dataset[i].HDOP ~= nil then
      HDOP = tonumber(dataset[i].HDOP)
    end
    if dataset[i].VDOP ~= nil then
      VDOP = tonumber(dataset[i].VDOP:sub(1, #dataset[i].VDOP-4))
    end
    if dataset[i].PDOP ~= nil then
      PDOP = tonumber(dataset[i].PDOP)
    end
--    print(HDOP, VDOP, PDOP)

    if dataset[i].height ~= nil and dataset[i].height ~= '' then
      height = dataset[i].height
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

    local timestamp = dataset[i].timstamp or dataset[i].timestamp
    if timestamp ~= nil then tstep = timestamp end
    if dataset[i].type ~= nil then datatype = dataset[i].type end
    
--    print(latitude, longtitude, height)
    if coorInit == false and heightInit and latitudeInit and longtitudeInit then
      print(latitude, longtitude, height)
      proj = LocalCartesian.new(latitude, longtitude, height, earth)
      coorInit = true
    end

    if coorInit and positionUpdate then
      ret = proj:Forward(latitude, longtitude, height)
--      print(ret.x, ret.y, ret.z, HDOP, VDOP, PDOP, latitude, longtitude)
      dopcounter = dopcounter + 1
      local lgps = {}
      lgps.timestamp = timestamp
      lgps.type = datatype
      lgps.x = ret.x
      lgps.y = ret.y
      lgps.z = ret.z
      lgps.latitude = latitude
      lgps.longtitude = longtitude
      lgps.HDOP = HDOP
      lgps.VDOP = VDOP
      lgps.PDOP = PDOP
      gpsLocal[#gpsLocal+1] = lgps
--      gpsstr = serialization.serialize(lgps)
--      print(gpsstr)
--      gpsmp = mp.pack(lgps)
--      print(#gpsstr, #gpsmp)
--      print(gpsmp:byte(1, #gpsmp))
--      print(gpsmp)
--      local lg = mp.unpack(gpsstr)
    end
  end
end

print(#gpsLocal, dopcounter)
--saveData(gpsLocal, 'gpsLocal')
saveDataMP(gpsLocal, 'gpsLocalMP', './')
--local dataset = loadDataMP('./', 'gpsLocal', _, 1)
--print(#dataset)

