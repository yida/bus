require 'include'
require 'common'
require 'gpscommon'

local pwd = os.getenv('PWD')
package.cpath = pwd..'/luaGeographicLib/?.so;'..package.cpath

local geo = require 'GeographicLib'


local datasetpath = '../data/010213180247/'
local gpsset = loadData(datasetpath, 'gps')

gps = {}
gpscount = 0

function findDateFromGPS(gps)
  local date = ""
  for i = 1, #gps do
    if gps[i].datastamp ~= nil and gps[i].datastamp ~= "" then
      date = gps[i].datastamp..gps[i].utctime
  --    print('\r'..gps[i].datastamp, gps[i].utctime)
      break;
    end
  end
  return date
end

--print(findDateFromGPS(gpsset))
local firstlat = true
local basepos = {0.0, 0.0, 0.0}
for i = 1, #gpsset do
  if gpsset[i].latitude and gpsset[i].latitude ~= '' then
    lat, lnt = nmea2degree(gpsset[i].latitude, gpsset[i].northsouth, gpsset[i].longtitude, gpsset[i].eastwest)
    pos = geo.Forward(lat, lnt, 6)
    if firstlat then
      basepos = pos
      firstlat = false
    else
      print(pos.x - basepos.x, pos.y - basepos.y, pos.z - basepos.z)
    end
  end
end
