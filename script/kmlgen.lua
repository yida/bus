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

--for cnt = 1, 1 do -- #labelgps do
documentlist = {}
documentlist[1] = objectGen('name', {''})
documentlist[2] = objectGen('description', {''})
for cnt = 1, #labelgps do



  coordinate = objectGen('coordinate', {labelgps[cnt].longtitude..','..labelgps[cnt].latitude..','..0})
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
