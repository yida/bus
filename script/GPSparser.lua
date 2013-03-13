
require 'include'
local util = require 'util'

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
--  for k, v in pairs(value) do
--    print(k, v)
--  end
  return value
end

function readGPSLine(str, len, startptr)
  local gps = {}
  gps.type = 'gps'
  gps.timstamp = tonumber(string.sub(str, 1, 16))
  local startpt = startptr or 17
--  if str[17] ~= '$' then  
--    startpt = 19
--  end
  local line = string.sub(str, startpt)
--  print(line)
  local stype = string.sub(str, startpt, startpt+5)
  if stype == '$GPGGA' then
--    print('GPGGA'..line)
    value = split(line)
    gps.utctime = value[1]
    gps.latitude = value[2]
    gps.northsouth = value[3]
    gps.longtitude = value[4]
    gps.eastwest = value[5]
    gps.satellites = value[7]
    gps.HDOP = value[8]
    gps.height = value[9]
    gps.wgs84height = value[11]

  elseif stype == '$GPGLL' then 
--  print('GPGLL') 
    value = split(line)
    gps.utctime = value[5]
    gps.latitude = value[1]
    gps.northsouth = value[2]
    gps.longtitude = value[3]
    gps.eastwest = value[4]

  elseif stype == '$GPGSA' then 
--  print('GPGSA') 
    value = split(line)
    gps.PDOP = value[15]
    gps.HDOP = value[16]
    gps.VDOP = value[17]

  elseif stype == '$GPGSV' then
--  print('GPGSV') 
    value = split(line)
  elseif stype == '$GPRMC' then 
--  print('GPRMC') 
    value = split(line)
    gps.utctime = value[1]
    gps.latitude = value[3]
    gps.northsouth = value[4]
    gps.longtitude = value[5]
    gps.eastwest = value[6]
    gps.nspeed = value[7]
    gps.truecourse = value[8]
    gps.datastamp = value[9]
    gps.magneticvar = value[10]
    gps.magneticvard = value[11]
  elseif stype == '$GPVTG' then 
--    print('GPVTG') 
    value = split(line)
    gps.truecourse = value[1]
    gps.magneticcourse = value[3]
    gps.nspeed = value[5]
    gps.kspeed = value[7]
  else
  end

  return gps;
end

function iterateGPS(data, xmlroot)
  local gpsset = {}
  local gpscounter = 0
  for i = 0, data.FileNum - 1 do
    local fileName = data.Path..data.Type..data.Stamp..i
    local file = assert(io.open(fileName, 'r+'))
    local line = file:read("*all");
    local lfpos = string.find(line, '\n', 1)
    local lastlfpos = 0;
    while lfpos ~= nil do
      local substr = string.sub(line, lastlfpos + 1, lfpos)
      local len = lfpos - lastlfpos - 1 
      gps = readGPSLine(substr, len)
      local datacheck = checkData(gps)
      datacheck = true
      if datacheck and util.tablesize(gps) > 3 then
        gpscounter = gpscounter + 1
        gpsset[gpscounter] = gps
      else
--        print('datecheck fail')
      end
      lastlfpos = lfpos
      lfpos = string.find(line, '\n', lfpos + 1)
    end
    file:close();
  end
  return gpsset
end

function parseGPS()
  local data = loadRawData(dataPath, dataStamp, 'gps')

  gpsset = iterateGPS(data)

  return gpsset
end
