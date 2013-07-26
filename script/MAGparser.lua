function readMAGLine(str, len, labeloffset)
  local carray = require 'carray'
  local cutil = require 'cutil'
  local mag = {}
  local ts_len = len or 16
  if labeloffset > 0 then
    label = {}
    label.type = 'label'
    label.timstamp = tonumber(string.sub(str, 1, ts_len))
    label.value = str:sub(ts_len + 1, ts_len + 1)
  end
  mag.type = 'mag'
  mag.timstamp = tonumber(string.sub(str, 1, ts_len))
  ls = ts_len + labeloffset

  mag.id = str:byte(ls + 1)
  mag.tuc = cutil.bit_or(str:byte(ls + 2), 
                        cutil.bit_lshift(str:byte(ls + 3), 8), 
                        cutil.bit_lshift(str:byte(ls + 4), 16), 
                        cutil.bit_lshift(str:byte(ls + 5), 24));
  mag.press = carray.short({cutil.bit_or(cutil.bit_lshift(str:byte(ls +  7), 8), str:byte(ls +  6))})[1] + 100000
  mag.temp = carray.short({cutil.bit_or(cutil.bit_lshift(str:byte(ls +  11), 8), str:byte(ls + 10))})[1] / 100
--  print(mag.id, mag.tuc, mag.press, mag.temp)
  mag.x = carray.short({cutil.bit_or(cutil.bit_lshift(str:byte(ls +  15), 8), str:byte(ls +  14))})[1]
  mag.y = carray.short({cutil.bit_or(cutil.bit_lshift(str:byte(ls + 17), 8), str:byte(ls +  16))})[1]
  mag.z = carray.short({cutil.bit_or(cutil.bit_lshift(str:byte(ls + 19), 8), str:byte(ls + 18))})[1]
--  print(mag.x, mag.y, mag.z)
  return mag, label
end

function checkData(mag)
  -- check time stamp, not readable or not reasonable
  -- unix time between 01012000, 00:00:00 to 01012000, 23:00:00
  if mag.timstamp == nil then return false end
  if mag.timstamp < 946684800 or mag.timstamp > 946767600 then return false end
  return true
end

local pattern = '%d%d%d%d%d%d%d%d%d%.%d%d%d%d%d%d'
function iterateMAG(data, xmlroot, labeloffset)
  local labeloffset = labeloffset or 0
  local magset = {}
  local labelset = {}
  local magcounter = 0
--  for i = 0, 0 do -- data.FileNum - 1 do
  for i = 0, data.FileNum - 1 do
    local fileName = data.Path..data.Type..data.Stamp..i
    print(fileName)
    local file = assert(io.open(fileName, 'r+'))
    local line = file:read("*a");
    local lastlfpos = string.find(line, pattern, 1)
    local lfpos = string.find(line, pattern, lastlfpos + 1)
    while lfpos ~= nil do
      local len = lfpos - lastlfpos - 1
      local substr = string.sub(line, lastlfpos, lfpos-1)
      --print(string.byte(substr, 1, lfpos - lastlfpos)) 
      local lencheck = checkLen(36 + labeloffset, #substr)
      if lencheck then
        mag, label = readMAGLine(substr, len, labeloffset)
--        local datacheck = checkData(mag)
--        local tdata = os.date('*t', mag.timestamp)
--        print(mag.timstamp, mag.tuc, mag.press, mag.temp, mag.x, mag.y, mag.z)
----        print(mag.timstamp, tdata.year, tdata.month, tdata.day, tdata.hour, tdata.min, tdata.sec)
        magcounter = magcounter + 1
        magset[#magset + 1] = mag
        if label then
          labelset[#labelset + 1] = label
        end
      else
        print('lencheck fail '..len)
      end
      lastlfpos = lfpos
      lfpos = string.find(line, pattern, lastlfpos + 1)
    end
    file:close();
  end
  return magset, labelset
end

function parseMAG(labeloffset)
  local data = loadRawData(dataPath, dataStamp, 'mag')
  magset, labelset = iterateMAG(data, _, labeloffset)

  return magset, labelset
end

