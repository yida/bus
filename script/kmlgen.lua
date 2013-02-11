local pwd = os.getenv("PWD")
package.path = pwd..'/LuaXml/?.lua;'..package.path
package.cpath = pwd..'/LuaXml/?.so;'..package.cpath

require('LuaXml')

require 'include'
require 'common'
require 'gpscommon'
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

--for cnt = 1, 1 do -- #labelgps do
documentlist = {}
documentlist[1] = objectGen('name', {'dataset'})
documentlist[2] = objectGen('description', {'data set'})
documentlistcount = 3

lastlabel = {}
for cnt = 2, #labelgps  do
  
  if labelgps[cnt].value ~= lastlabel.value and labelgps[cnt].longtitude ~= lastlabel.longtitude then
    lastlabel = labelgps[cnt]

    Lat, Lnt = nmea2degree(labelgps[cnt].latitude, labelgps[cnt].northsouth,
                            labelgps[cnt].longtitude, labelgps[cnt].eastwest)
    print(labelgps[cnt].latitude, labelgps[cnt].value)
  
    coordinate = objectGen('coordinates', {Lnt..','..Lat..','..0})
    altitudeMode = objectGen('altitudeMode', {'relativeToGround'})
    extrude = objectGen('extrude', {1})
  
    point = objectGen('Point', {coordinate, altitudeMode, extrude})
  
    pmname = objectGen('name', {"point"})
    pmdes = objectGen('description', {"point des"})
    placemark = objectGen('Placemark', {pmname, pmdes, point})
  
    documentlist[documentlistcount] = placemark
    documentlistcount = documentlistcount + 1 
  end
end

document = objectGen('Document', documentlist)

kml = {}
kml[0] = 'kml'
kml.xmlns="http://www.opengis.net/kml/2.2"
kml[1] = document

root = xml.new(kml)
xml.save(root, 'root.kml')
