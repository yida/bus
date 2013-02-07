local pwd = os.getenv("PWD")
package.path = pwd..'/LuaXml/?.lua;'..package.path
package.cpath = pwd..'/LuaXml/?.so;'..package.cpath

require('LuaXml')

require 'include'
require 'common'
local util = require 'util'

local datasetpath = './'
labelgps = loadData(datasetpath, 'labelgps')

print(#labelgps)

function objectGen(name, value, tag)
  object = {}
  object[0] = name
  for k, v in pairs(value) do
    object[k] = v
  end
  return object
end

function nmea2degree(lat, latD, lnt, lntD)
  
  local nmea2deg = function(value, dir)
    local degree = math.floor(value/100 + 0.5)
    local minute = value - degree * 100
    deg = degree + minute / 60
    if dir == 'S' or dir == 'W' then deg = -deg end
    return deg
  end
  Lat = nmea2deg(lat, latD)
  Lnt = nmea2deg(lnt, lntD)
  return Lat, Lnt
end

--for cnt = 1, 1 do -- #labelgps do
documentlist = {}
documentlist[1] = objectGen('name', {''})
documentlist[2] = objectGen('description', {''})
for cnt = 1, #labelgps do

  Lat, Lnt = nmea2degree(labelgps[cnt].latitude, labelgps[cnt].northsouth,
                          labelgps[cnt].longtitude, labelgps[cnt].eastwest)
  print(Lat, Lnt)

  coordinate = objectGen('coordinate', {Lnt..','..Lat..','..0})
  altitudeMode = objectGen('altitudeMode', {'relativeToGround'})
  extrude = objectGen('extrude', {1})

  point = objectGen('Point', {coordinate, altitudeMode, extrude})

  placemark = objectGen('Placemark', point)

  documentlist[cnt + 2] = placemark
end

document = objectGen('Document', documentlist)

kml = {}
kml[0] = 'kml'
kml.xmlns="http://www.opengis.net/kml/2.2"
kml[1] = document

root = xml.new(kml)
xml.save(root, 'root.xml')
