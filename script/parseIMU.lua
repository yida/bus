local ffi = require 'ffi'
local bit = require 'bit'

function readImuLine(str, len)
  local imu = {}
  imu.type = 'imu'
  imu.timstamp = tonumber(string.sub(str, 1, 16))

  imustrs = string.sub(str, len - 24, len - 1)
  assert(#imustrs == 24)
  imustr = ffi.new("uint8_t[?]", #imustrs, imustrs)
  imu.tuc = tonumber(ffi.new("uint32_t", bit.bor(bit.lshift(imustr[3], 24),
                                      bit.lshift(imustr[2], 16), bit.lshift(imustr[1], 8), imustr[0])))
  imu.id = tonumber(ffi.new("double", imustr[4]))
  imu.cntr = tonumber(ffi.new("double", imustr[5]))
  rpyGain = 5000
  imu.r = bit.bor(bit.lshift(imustr[7], 8), imustr[6]) / rpyGain
  imu.p = bit.bor(bit.lshift(imustr[9], 8), imustr[8]) / rpyGain
  imu.y = bit.bor(bit.lshift(imustr[11], 8), imustr[10]) / rpyGain
  wrpyGain = 500
  imu.wr = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[13], 8), imustr[12]))) / wrpyGain
  imu.wp = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[15], 8), imustr[14]))) / wrpyGain
  imu.wy = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[17], 8), imustr[16]))) / wrpyGain
  accGain = 5000
  imu.ax = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[19], 8), imustr[18]))) / accGain
  imu.ay = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[21], 8), imustr[20]))) / accGain
  imu.az = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[23], 8), imustr[22]))) / accGain
  return imu;
end

function checkData(imu)
  -- check time stamp, not readable or not reasonable
  -- unix time between 01012000, 00:00:00 to 01012000, 23:00:00
  if imu.timstamp == nil then return false end
  if imu.timstamp < 946684800 or imu.timstamp > 946767600 then return false end
  return true
end

function checkLen(value, len)
  if len == value then
    return true
  else
    return false
  end
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
      local lencheck = checkLen(44, len) or checkLen(40, len)
--      print(len, lencheck)
      if lencheck then
        imu = readImuLine(substr, len)
        local datacheck = checkData(imu)
        if datacheck then
          local tdata = os.date('*t', imu.timestamp)
--          print(imu.timstamp, tdata.year, tdata.month, tdata.day, tdata.hour, tdata.min, tdata.sec)
          imucounter = imucounter + 1
          imuset[imucounter] = imu
        else
--        print('datecheck fail')
        end
      else
--      print('lencheck fail '..len)
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

