require 'ucm'

require 'include'
require 'common'
require 'poseUtils'
require 'torch-load'
require 'GPSUtils'

local serialization = require('serialization');

local datasetpath = '../data/150213185940/'
--local datasetpath = '../data/010213180247/'
--local datasetpath = '../data/010213192135/'
--local datasetpath = '../data/191212190259/'
--local datasetpath = '../data/211212164337/'
--local datasetpath = '../data/211212165622/'
local dataset = loadData(datasetpath, 'gps', _, 1)

earth = Geocentric.new(Constants.WGS84_a(), Constants.WGS84_f())
coorInit = false

local counter = 0
local labelcounter = 0
local gpsLocal = {}
local dopcounter = 0
local HDOP = '0'
local VDOP = '0*06'
local PDOP = '0'
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
      VDOP = tonumber(dataset[i].VDOP:sub(1, #dataset[i].VDOP-3))
    end
    if dataset[i].PDOP ~= nil then
      PDOP = tonumber(dataset[i].PDOP)
    end

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
      proj = LocalCartesian.new(latitude, longtitude, height, earth)
      coorInit = true
    end

    if coorInit and positionUpdate then
      ret = proj:Forward(latitude, longtitude, height)
      print(ret.x, ret.y, ret.z, HDOP, VDOP, PDOP, latitude, longtitude)
      dopcounter = dopcounter + 1
      local lgps = {}
      lgps.timestamp = timestamp
      lgps.type = datatype
      lgps.x = ret.x
      lgps.y = ret.y
      lgps.z = ret.z
      lgps.latitude = latitude
      lgps.longtitude = longtitude
      lgps.HDOP = ret.HDOP
      lgps.VDOP = ret.VDOP
      lgps.PDOP = ret.PDOP
      gpsLocal[#gpsLocal+1] = lgps
      gpsstr = serialization.serialize(lgps)
--      print(gpsstr)

    end

--    if dataset[i].latitude ~= nil and dataset[i].longtitude ~= nil and
--       dataset[i].latitude ~= '' and dataset[i].longtitude ~= '' then
--      local lat, lnt = nmea2degree(dataset[i].latitude, dataset[i].northsouth, 
--                                  dataset[i].longtitude, dataset[i].eastwest)
----      local gpspos = global2metric(dataset[i])
--      local lgps = {}
--      lgps.timestamp = dataset[i].timstamp or dataset[i].timestamp
--      lgps.type = dataset[i].type
--      if not coorInit then  
--        proj = LocalCartesian.new(lat, lnt, dataset[i].height, earth)
--        coorInit = true
--      else
--        ret = proj:Forward(lat, lnt, dataset[i].height)
----        print(ret.x, ret.y, ret.z)
--        lgps.x = ret.x
--        lgps.y = ret.y
--        lgps.z = ret.z
--        local tstep = dataset[i].timestamp
--        
--        counter = counter + 1         
--        gpsLocal[#gpsLocal+1] = lgps
--      end
--      gpsstr = serialization.serialize(lgps)
--    --  print(gpsstr)
----      usleep(0.01)
--    end
  end
end

print(#gpsLocal, dopcounter)
--saveData(gpsLocal, 'gpsLocal')
