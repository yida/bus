function readMagLine(str, len)
  local carray = require 'carray'
  local cutil = require 'cutil'
  local mag = {}
  mag.type = 'mag'
  mag.timstamp = tonumber(string.sub(str, 1, 16))
  ls = 16

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
--  for i = 0, 0 do -- data.FileNum - 1 do
  for i = 0, data.FileNum - 1 do
    local fileName = data.Path..data.Type..data.Stamp..i
    print(fileName)
    local file = assert(io.open(fileName, 'r+'))
    local line = file:read("*a");
    local lastlfpos = string.find(line, '9466', 1)
    local lfpos = string.find(line, '9466', lastlfpos + 1)
    while lfpos ~= nil do
      local len = lfpos - lastlfpos - 1
      local substr = string.sub(line, lastlfpos, lfpos-1)
      --print(string.byte(substr, 1, lfpos - lastlfpos)) 
      local lencheck = checkLen(36, #substr)
      if lencheck then
        mag = readMagLine(substr, len)
--        local datacheck = checkData(mag)
--        local tdata = os.date('*t', mag.timestamp)
--        print(mag.timstamp, mag.tuc, mag.press, mag.temp, mag.x, mag.y, mag.z)
----        print(mag.timstamp, tdata.year, tdata.month, tdata.day, tdata.hour, tdata.min, tdata.sec)
        magcounter = magcounter + 1
        magset[magcounter] = mag
      else
        print('lencheck fail '..len)
        print(line:byte(1, 20))
      end
      lastlfpos = lfpos
      lfpos = string.find(line, '9466', lastlfpos + 1)
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

