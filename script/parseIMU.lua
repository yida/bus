local ffi = require 'ffi'
local bit = require 'bit'

function readImuLine(str)
  local imu = {}
  imu.timstamp = tonumber(string.sub(str, 1, 16))
  imu.imustr = ffi.new("uint8_t[?]", #string.sub(str, 13), string.sub(str, 13))
  imu.tuc = ffi.new("uint32_t", bit.bor(bit.lshift(imustr[9], 24), bit.lshift(imustr[8], 16), bit.lshift(imustr[7], 8), imustr[6]))
  imu.id = ffi.new("double", imustr[10])
  imu.cntr = ffi.new("double", imustr[11])
  imu.rpyGain = 5000
  imu.r = bit.bor(bit.lshift(imustr[13], 8), imustr[12]) / rpyGain
  imu.p = bit.bor(bit.lshift(imustr[15], 8), imustr[14]) / rpyGain
  imu.y = bit.bor(bit.lshift(imustr[17], 8), imustr[16]) / rpyGain
  imu.wrpyGain = 500
  imu.wr = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[19], 8), imustr[18]))) / wrpyGain
  imu.wp = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[21], 8), imustr[20]))) / wrpyGain
  imu.wy = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[23], 8), imustr[22]))) / wrpyGain
  imu.accGain = 5000
  imu.ax = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[25], 8), imustr[24]))) / accGain
  imu.ay = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[27], 8), imustr[26]))) / accGain
  imu.az = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[29], 8), imustr[28]))) / accGain
  return imu;
end

function parseIMU()
  local data = loadData(dataPath, dataStamp, 'imu')
  local dataLen = 45;
  for i = 0, data.FileNum - 1 do
    local fileName = data.Path..data.Type..data.Stamp..i
    local file = assert(io.open(fileName, 'r+'))
    line = file:read(dataLen);
    while line ~= nil do
      imu = readImuLine(line)
      line = file:read(dataLen);
    end
    file:close();
  end
  print(data.FileNum)
end


