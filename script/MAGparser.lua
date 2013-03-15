local ffi = require 'ffi'
local bit = require 'bit'

function readMagLine(str, len)
  local mag = {}
  mag.type = 'mag'
  mag.timstamp = tonumber(string.sub(str, 1, 16))
  magstrs = string.sub(str, 17, #str)
  ls = #magstrs - 1
  magstr = ffi.new("uint8_t[?]", #magstrs, magstrs)
--  mag.id = tonumber(ffi.new("double", magstr[0]))
--  mag.tuc = tonumber(ffi.new("uint32_t", bit.bor(bit.lshift(magstr[ls - 15], 24),
--                    bit.lshift(magstr[ls - 16], 16), bit.lshift(magstr[ls - 17], 8), magstr[ls - 18])))
--  mag.press = tonumber(ffi.new('int16_t', bit.bor(bit.lshift(magstr[ls - 13], 8), magstr[ls - 14]))) + 100000
--  mag.temp = tonumber(ffi.new('int16_t', bit.bor(bit.lshift(magstr[ls - 9], 8), magstr[ls - 10]))) / 100
--  mag.x = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(magstr[ls - 5], 8), magstr[ls - 6])))
--  mag.y = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(magstr[ls - 3], 8), magstr[ls - 4])))
--  mag.z = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(magstr[ls - 1], 8), magstr[ls - 2])))
  return mag;
end

function checkData(mag)
  -- check time stamp, not readable or not reasonable
  -- unix time between 01012000, 00:00:00 to 01012000, 23:00:00
  if mag.timstamp == nil then return false end
  if mag.timstamp < 946684800 or mag.timstamp > 946767600 then return false end
  return true
end


function iterateMAG(data, xmlroot)
  local magset = {}
  local magcounter = 0
  for i = 0, 0 do -- data.FileNum - 1 do
--  for i = 0, data.FileNum - 1 do
    local fileName = data.Path..data.Type..data.Stamp..i
    print(fileName)
    local file = assert(io.open(fileName, 'r+'))
    local line = file:read("*a");
    local lastlfpos = string.find(line, '94668', 1)
    local lfpos = string.find(line, '94668', lastlfpos + 1)
    while lfpos ~= nil do
      local len = lfpos - lastlfpos - 1
      local substr = string.sub(line, lastlfpos, lfpos-1)
      print(#substr)
      --print(string.byte(substr, 1, lfpos - lastlfpos)) 
      local lencheck = checkLen(35, len) or checkLen(37, len)
      if lencheck then
        mag = readMagLine(substr, len)
        local datacheck = checkData(mag)
        local tdata = os.date('*t', mag.timestamp)
        print(mag.timstamp, mag.tuc, mag.press, mag.temp, mag.x, mag.y, mag.z)
--        print(mag.timstamp, tdata.year, tdata.month, tdata.day, tdata.hour, tdata.min, tdata.sec)
        magcounter = magcounter + 1
        magset[magcounter] = mag
      else
        print('lencheck fail '..len)
      end
      lastlfpos = lfpos
      lfpos = string.find(line, '94668', lastlfpos + 1)
    end
    file:close();
  end
  return magset
end

function parseMAG()
  local data = loadRawData(dataPath, dataStamp, 'mag')
  magset = iterateMAG(data)

  return magset
end

