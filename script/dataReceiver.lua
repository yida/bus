#!/usr/local/bin/luajit -

local home = '/home/yida/UPennTHOR/Player'

package.path = home..'/Util/?.lua;'..package.path
package.cpath = home..'/Lib/?.so;'..package.cpath

require 'include'
require 'poseUtils'
require 'torch-load'
require 'magUtils'
require 'common'
torch.setdefaulttensortype('torch.DoubleTensor')


local ffi = require 'ffi'
local serialization = require('serialization');
local util = require('util');
local Serial = require('Serial');
local kBPacket = require('kBPacket');

function gpioOpen(port)
  gpioExport = io.open('/sys/class/gpio/export', 'w')
  gpioExport:write(port)
  gpioExport:close()
end



baud = 230400;
dev = '/dev/ttyUSB0';
s1 = Serial.connect(dev, baud);

packetID = -1;
function ReceivePacket() 
  if packetID < 0 then
    packetID = kBPacket.create();
  end
  
  buf, buftype, bufsize = Serial.read(1000, 2000);

--  return buf, bufsize
  packet, packetType, packetSize, buf2, buf2type, buf2Size = kBPacket.processBuffer(packetID, buf, bufsize);

  return packet, packetSize;
end

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
  imu.tuc = tonumber(ffi.new("uint32_t", bit.bor(bit.lshift(imustr[8], 24),
                      bit.lshift(imustr[7], 16), bit.lshift(imustr[6], 8), imustr[5])))
  imu.id = tonumber(ffi.new("double", imustr[9]))
  imu.cntr = tonumber(ffi.new("double", imustr[10]))
  rpyGain = 5000
  imu.r =  tonumber(ffi.new('int16_t', bit.bor(bit.lshift(imustr[12], 8), imustr[11]))) / rpyGain
  imu.p =  tonumber(ffi.new('int16_t', bit.bor(bit.lshift(imustr[14], 8), imustr[13]))) / rpyGain
  imu.y =  tonumber(ffi.new('int16_t', bit.bor(bit.lshift(imustr[16], 8), imustr[15]))) / rpyGain
  wrpyGain = 500
  imu.wr = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[18], 8), imustr[17]))) / wrpyGain
  imu.wp = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[20], 8), imustr[19]))) / wrpyGain
  imu.wy = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[22], 8), imustr[21]))) / wrpyGain
  accGain = 5000
  imu.ax = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[24], 8), imustr[23]))) / accGain
  imu.ay = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[26], 8), imustr[25]))) / accGain
  imu.az = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(imustr[28], 8), imustr[27]))) / accGain
  return imu;
end

function extractMag(magstr, len)
  local mag = {}
  mag.type = 'mag'

  mag.id = tonumber(ffi.new("double", magstr[5]))
  mag.tuc = tonumber(ffi.new("uint32_t", bit.bor(bit.lshift(magstr[9], 24),
                    bit.lshift(magstr[8], 16), bit.lshift(magstr[7], 8), magstr[6])))
  mag.press = tonumber(ffi.new('int16_t', bit.bor(bit.lshift(magstr[11], 8), magstr[10]))) + 100000
  mag.temp =  tonumber(ffi.new('int16_t', bit.bor(bit.lshift(magstr[15], 8), magstr[14]))) / 100
  mag.x = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(magstr[19], 8), magstr[18])))
  mag.y = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(magstr[21], 8), magstr[20])))
  mag.z = tonumber(ffi.new("int16_t", bit.bor(bit.lshift(magstr[23], 8), magstr[22])))
  return mag;
end

function extractGPS(gpsstr, len)
  local gps = {}
  gps.type = 'gps'
  gps.line = str
  return gps
end


function pcdata(cdata, size)
  str = ''
  for i = 0, size - 1 do
    str = str..' '..cdata[i]
  end
  print(str)
end

-- Flag to enable and disable certain type of data
imuFlag = true
magFlag = true 
gpsFlag = false
labelFlag = false 
fileSaveFlag = false

-- Create files
if fileSaveFlag then
  filecnt = 0;
  filetime = utime();
  filepath = home
  filename = string.format(filepath.."/log-%s-%d", filetime, filecnt);
  
  file = io.open(filename, "w");
end
linecount = 0;
maxlinecount = 500;

-- open button
if labelFlag then
  gpioOpen(147)
  gpioOpen(146)
  gpioOpen(175)
  gpioOpen(114)
end

gyro = torch.DoubleTensor(3, 1):fill(0)
acc = torch.DoubleTensor(3, 1):fill(0)

while (1) do

  local timestamp = utime()
  if labelFlag then
    gpio147 = io.open('/sys/class/gpio/gpio147/value', 'r')
    b1 = gpio147:read('*number')
    gpio147:close()

    gpio146 = io.open('/sys/class/gpio/gpio146/value', 'r')
    b2 = gpio146:read('*number')
    gpio146:close()

    gpio175 = io.open('/sys/class/gpio/gpio175/value', 'r+')
    b3 = gpio175:read('*number')
    gpio175:close()

    gpio114 = io.open('/sys/class/gpio/gpio114/value', 'r+')
    b4 = gpio114:read('*number')
    gpio114:close()

    if fileSaveFlag then
      butstr = b1..b2..b3..b4
      if butstr ~= '0000' then
        local data = {}
        data.type = 'label'
        data.timestamp = timestamp
        data.value = butstr
        savedata = serialization.serialize(data)
        file:write(savedata)
        file:write('\n')
        print(linecount, savedata)
        linecount = linecount + 1
      end
      if linecount >= maxlinecount then
        linecount = 0;
        file:close();
        filecnt = filecnt + 1;
        filename = string.format(filepath.."/log-%s-%d", filetime, filecnt);
        file = io.open(filename, "w");
      end
    end
  end

  packet, size = ReceivePacket();
  if (type(packet) == 'userdata') then
    local rawdata = ffi.cast('uint8_t*', packet)
    local data = nil
    if rawdata[2] == 0 then
      if rawdata[4] == 31 and gpsFlag then
        str = cdata2gpsstring(rawdata, size)
        data = extractGPS(str, #str)
        data.timestamp = timestamp
      elseif rawdata[4] == 34 and imuFlag then
        data = extractImu(rawdata, size)
        data.timestamp = timestamp
        gyro[1] = data.r
        gyro[2] = data.p
        gyro[3] = -data.y

        acc[1] = data.ax
        acc[2] = data.ay
        acc[3] = -data.az
      elseif rawdata[4] == 35 and magFlag then
        data = extractMag(rawdata, size)

        magv = torch.DoubleTensor({data.y, data.x, -data.z})
        magval = magCalibrated(magv)
        print(magv)
        print(magval)
        magvalue = magTiltCompensate(magv, acc)
        print(magvalue)
--        local heading = Mag2Heading(magvalue)
        local heading = Mag2Heading(magval)
        local heading1 = Mag2Heading(magvalue)
        print('w/o tilt compensation '..heading * 180 / math.pi)
        print('w tilt compensation '..heading1 * 180 / math.pi)
        data.timestamp = timestamp
      end
--      if data and fileSaveFlag then
--        savedata = serialization.serialize(data)
--        file:write(savedata)
--        file:write('\n')
--        print(linecount, savedata)
--        linecount = linecount + 1
--      end
    end
  end
--  if linecount >= maxlinecount and fileSaveFlag then
--    linecount = 0;
--    file:close();
--    filecnt = filecnt + 1;
--    filename = string.format(filepath.."/log-%s-%d", filetime, filecnt);
--    file = io.open(filename, "w");
--  end

end

if fileSaveFlag then file:close(); end
