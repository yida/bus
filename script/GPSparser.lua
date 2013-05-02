
require 'include'
local util = require 'util'
require 'GPSUtils'

function split(str)
  local value = {}
  local valuecounter = 0
  cmpos = string.find(str, ',', 1)
  lastcmpos = cmpos
  cmpos = string.find(str, ',', cmpos + 1)
--  print(str)
  while cmpos ~= nil do
--    print(cmpos, str:sub(lastcmpos + 1, cmpos - 1))
    valuecounter = valuecounter + 1
    value[valuecounter] = str:sub(lastcmpos + 1, cmpos - 1)
    lastcmpos = cmpos
    cmpos = string.find(str, ',', cmpos + 1)
  end
--  print(str:sub(lastcmpos + 1, #str))
  valuecounter = valuecounter + 1
  value[valuecounter] = str:sub(lastcmpos + 1, #str)
  return value
end

function iterateGPS(data, xmlroot)
  local gps = {}
  local gpscounter = 0
  for i = 0, data.FileNum - 1 do
    local fileName = data.Path..data.Type..data.Stamp..i
    local file = assert(io.open(fileName, 'r+'))
    local line = file:read("*all");
    local lfpos = string.find(line, '\n', 1)
    local lastlfpos = 0;
    while lfpos ~= nil do
      local substr = string.sub(line, lastlfpos + 1, lfpos)
--      print(substr)
      local len = lfpos - lastlfpos - 1 
      local gpstart = substr:find('$GP') or 1
      if gpsChecksum(substr:sub(gpstart, #substr)) then
        gpsContent = readGPSLine(substr, len, 19)
        local datavalid = gpsDataCheck(gpsContent)
        if datavalid then gps[#gps+1] = gpsContent end
      end
      lastlfpos = lfpos
      lfpos = string.find(line, '\n', lfpos + 1)
    end
    file:close();
  end
  return gps
end

function parseGPS()
  local data = loadRawData(dataPath, dataStamp, 'gps')

  gpsset = iterateGPS(data)

  return gpsset
end
