local ffi = require 'ffi'
local bit = require 'bit'

function readImuLine(str, len)
  local imu = {}
  imu.type = 'imu'
  imu.timstamp = tonumber(string.sub(str, 1, 16))
  substr = str:sub(17, #str)
--  print(substr:byte(1, #str), #str)
  imustrs = substr
  ls = #substr - 2

--  imustrs = string.sub(str, len - 24, len - 1)
--  assert(#imustrs == 24)
  imustr = ffi.new("uint8_t[?]", #imustrs, imustrs)
--  print(imustr[ls])
  imu.tuc = tonumber(ffi.new("uint32_t", bit.bor(bit.lshift(imustr[ls - 20], 24),
                                      bit.lshift(imustr[ls - 21], 16), bit.lshift(imustr[ls - 22], 8), imustr[ls - 23])))
  imu.id = tonumber(ffi.new("double", imustr[ls - 19]))
  imu.cntr = tonumber(ffi.new("double", imustr[ls - 18]))
  rpyGain = 5000
  imu.r =  tonumber(ffi.new('int16_t', bit.bor(bit.lshift(imustr[ls - 16], 8), imustr[ls - 17]))) / rpyGain
  imu.p =  tonumber(ffi.new('int16_t', bit.bor(bit.lshift(imustr[ls - 14], 8), imustr[ls - 15]))) / rpyGain
  imu.y =  tonumber(ffi.new('int16_t', bit.bor(bit.lshift(imustr[ls - 12], 8), imustr[ls - 13]))) / rpyGain
  wrpyGain = 500
  imu.wr = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[ls - 10], 8), imustr[ls - 11]))) / wrpyGain
  imu.wp = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[ls - 8], 8), imustr[ls - 9]))) / wrpyGain
  imu.wy = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[ls - 6], 8), imustr[ls - 7]))) / wrpyGain
  accGain = 5000
  imu.ax = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[ls - 4], 8), imustr[ls - 5]))) / accGain
  imu.ay = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[ls - 2], 8), imustr[ls - 3]))) / accGain
  imu.az = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[ls], 8), imustr[ls - 1]))) / accGain
  return imu;
end

function checkData(imu)
  -- check time stamp, not readable or not reasonable
  -- unix time between 01012000, 00:00:00 to 01012000, 23:00:00
  if imu.timstamp == nil then return false end
  if imu.timstamp < 946684800 or imu.timstamp > 946767600 then return false end
  return true
end

function iterateIMU(data, xmlroot)
  local imuset = {}
  local imucounter = 0
--  for i = 0, 0 do -- data.FileNum - 1 do
  for i = 0, data.FileNum - 1 do
    local fileName = data.Path..data.Type..data.Stamp..i
    print(fileName)
    local file = assert(io.open(fileName, 'r+'))
    local line = file:read("*all");
    local lfpos = string.find(line, '\n', 1)
    local lastlfpos = 0;
    while lfpos ~= nil do
      local substr = string.sub(line, lastlfpos + 1, lfpos)
      --print(substr)
      --print(string.byte(substr, 1, lfpos - lastlfpos)) 
      local len = lfpos - lastlfpos - 1 
      local lencheck = checkLen(44, len) or checkLen(40, len) or checkLen(42, len)
--      print(len, lencheck)
      if lencheck then
        imu = readImuLine(substr, len)
        local datacheck = checkData(imu)
        if datacheck then
          local tdata = os.date('*t', imu.timestamp)
          print(imu.timstamp, imu.tuc, imu.r, imu.p, imu.y, imu.wr, imu.wp, imu.wy, imu.ax, imu.ay, imu.az)
--          print(imu.timstamp, tdata.year, tdata.month, tdata.day, tdata.hour, tdata.min, tdata.sec)
          imucounter = imucounter + 1
          imuset[imucounter] = imu
        else
        print('datecheck fail')
        end
      else
      print('lencheck fail '..len)
      end
      lastlfpos = lfpos
      lfpos = string.find(line, '\n', lfpos + 1)
    end
    file:close();
  end
  return imuset
end

function parseIMU()
  local data = loadRawData(dataPath, dataStamp, 'imu')
  imuset = iterateIMU(data)

  return imuset
end

