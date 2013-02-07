require 'include'

local ffi = require 'ffi'
local serialization = require('serialization');
local util = require 'util'
require('Serial');
require('kBPacket');
require('unix');

require 'parseIMU'

--dev = '/dev/ttyUSB0';
--baud = 230400;
dev = '/dev/ttyUSB0';
baud = 115200;
s1 = Serial.connect(dev, baud);

packetID = -1;
function ReceivePacket() 
  if packetID < 0 then
    packetID = kBPacket.create();
  end
  
  buf, buftype, bufsize = Serial.read(1000, 20000);

--  return buf, bufsize
  packet, packetType, packetSize, buf2, buf2type, buf2Size = kBPacket.processBuffer(packetID, buf, bufsize);

  return packet, packetSize;
end

-- Create files
function cdata2gpsstring(cdata, len)
  str = '';
  for i = 5, len - 1 - 8 do
    str = str..string.format('%c', cdata[i])
  end
  return str
end

function cdata2string(cdata, len)
  str = '';
  for i = 0, len - 1 do
    str = str..string.format('%c', cdata[i])
  end
  return str
end

function extractImu(imustr, len)
  local imu = {}
  imu.type = 'imu'

--  imustr = ffi.new("uint8_t[?]", #imustrs, imustrs)
  imu.tuc = tonumber(ffi.new("uint32_t", bit.bor(bit.lshift(imustr[9], 24),
                      bit.lshift(imustr[8], 16), bit.lshift(imustr[7], 8), imustr[6])))
  imu.id = tonumber(ffi.new("double", imustr[10]))
  imu.cntr = tonumber(ffi.new("double", imustr[11]))
  rpyGain = 5000
  imu.r = bit.bor(bit.lshift(imustr[13], 8), imustr[12]) / rpyGain
  imu.p = bit.bor(bit.lshift(imustr[15], 8), imustr[14]) / rpyGain
  imu.y = bit.bor(bit.lshift(imustr[17], 8), imustr[16]) / rpyGain
  wrpyGain = 500
  imu.wr = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[19], 8), imustr[18]))) / wrpyGain
  imu.wp = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[21], 8), imustr[20]))) / wrpyGain
  imu.wy = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[23], 8), imustr[22]))) / wrpyGain
  accGain = 5000
  imu.ax = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[25], 8), imustr[24]))) / accGain
  imu.ay = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[27], 8), imustr[26]))) / accGain
  imu.az = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[29], 8), imustr[28]))) / accGain
  return imu;
end



while (1) do
  t1 = unix.time();
  packet, size = ReceivePacket();
  if (type(packet) == 'userdata') then
    data = ffi.cast('uint8_t*', packet)
    print(data[0])
    if data[4] == 31 then
      str = cdata2gpsstring(data, size)
--      print(data[4], size, str)
    elseif data[4] == 34 then
--      print(data[4], size)
      imu = extractImu(data, size)
      print(imu.r)
--      util.ptable(imu)
    elseif data[4] == 35 then
--      print(data[4], size)
    end
  end

end

file:close();
