#!/usr/local/bin/luajit -

local home = '/Users/Yida/'

package.path = home..'/Util/?.lua;'..package.path
package.cpath = home..'/Lib/?.so;'..package.cpath

require 'include'
require 'poseUtils'
require 'torch'
require 'unix'
require 'cutil'
require 'carray'
require 'magUtils'
require 'common'
require 'imuParser'
require 'MAGparser'
require 'getch'

getch.enableblock(1);

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
dev = '/dev/tty.usbserial-A1017G1T';
s1 = Serial.connect(dev, baud);

packetID = -1;
function ReceivePacket() 
  if packetID < 0 then
    packetID = kBPacket.create();
  end
  
  buf, buftype, bufsize = Serial.read(100, 200);

--  return buf, bufsize
  packet, packetType, packetSize, buf2, buf2type, buf2Size = kBPacket.processBuffer(packetID, buf, bufsize);

  return packet, packetSize;
end

-- Flag to enable and disable certain type of data
imuFlag = true
magFlag = true 
gpsFlag = true 
labelFlag = true 
fileSaveFlag = true

-- Create files
if fileSaveFlag then
  if imuFlag then
    imu_filecnt = 0;
    imu_filetime = os.date('%m%d%Y%H%M')
    imu_filepath = home
    imu_filename = string.format(imu_filepath.."/log-imu-%s-%d", imu_filetime, imu_filecnt);
    imu_file = io.open(imu_filename, "w");
    imu_linecount = 0;
  end
  if magFlag then
    mag_filecnt = 0;
    mag_filetime = os.date('%m%d%Y%H%M')
    mag_filepath = home
    mag_filename = string.format(mag_filepath.."/log-mag-%s-%d", mag_filetime, mag_filecnt);
    mag_file = io.open(mag_filename, "w");
    mag_linecount = 0;
  end
  if gpsFlag then
    gps_filecnt = 0;
    gps_filetime = os.date('%m%d%Y%H%M')
    gps_filepath = home
    gps_filename = string.format(gps_filepath.."/log-gps-%s-%d", gps_filetime, gps_filecnt);
    gps_file = io.open(gps_filename, "w");
    gps_linecount = 0;
  end
  if labelFlag then
    label_filecnt = 0;
    label_filetime = os.date('%m%d%Y%H%M')
    label_filepath = home
    label_filename = string.format(label_filepath.."/log-label-%s-%d", label_filetime, label_filecnt);
    label_file = io.open(label_filename, "w");
    label_linecount = 0;
  end
end
maxlinecount = 5000;

t0 = unix.time()
while (1) do

  local timestamp = unix.time()

  packet, size = ReceivePacket();

  if (type(packet) == 'userdata') then
    packet_array = carray.byte(packet, size);
    packet_str = tostring(packet_array);
    -- check data valid
    if packet_str:byte(3) == 0 then
      if packet_str:byte(5) == 31 and gpsFlag then
--        print('gps :', size, packet_str:sub(6, #packet_str - 8))
          gps_str = string.format('%10.6f', timestamp)..packet_str:sub(6, #packet_str - 8)
          gps_file:write(gps_str)
          print(gps_str)
          gps_linecount = gps_linecount + 1
      elseif packet_str:byte(5) == 34 and imuFlag then
          imu, label = readImuLine(string.format('%10.5f', timestamp)..packet_str:sub(6, 29), 40, 0);  
          imu_str = string.format('%10.6f', timestamp)..packet_str:sub(6, 29)
          imu_file:write(imu_str)
          imu_linecount = imu_linecount + 1
--          print(imu.tuc, imu.r, imu.p, imu.y, imu.wr, imu.wp, imu.wy, imu.ax, imu.ay, imu.az)
--        print('imu :', size, packet_str:byte(6, 29))
      elseif packet_str:byte(5) == 35 and magFlag then
          mag_str = string.format('%10.6f', timestamp)..packet_str:sub(6, 24)
          mag_file:write(mag_str)
          mag, label = readMagLine(string.format('%10.5f', timestamp)..packet_str:sub(6, 24), 40, 0);
          mag_linecount = mag_linecount + 1
--        print('mag :', size, packet_str:byte(6, 24))
      end
    end
  end

  if labelFlag then
    local str = getch.get();
    if #str > 0 then
      local byte = string.byte(str, 1)
      if byte == string.byte("1") then
        print('left start')
        label_str = string.format('%10.6f', timestamp)..'1000'
        label_file:write(label_str)
        label_linecount = label_linecount + 1
      elseif byte == string.byte("2") then
        print('left end')
        label_str = string.format('%10.6f', timestamp)..'0100'
        label_file:write(label_str)
        label_linecount = label_linecount + 1
      elseif byte == string.byte("3") then
        print('right start')
        label_str = string.format('%10.6f', timestamp)..'0010'
        label_file:write(label_str)
        label_linecount = label_linecount + 1
      elseif byte == string.byte("4") then
        print('right end')
        label_str = string.format('%10.6f', timestamp)..'0001'
        label_file:write(label_str)
        label_linecount = label_linecount + 1
      end
    end
  end
  
  if imu_linecount >= maxlinecount and fileSaveFlag then
    imu_linecount = 0;
    imu_file:close();
    imu_filecnt = imu_filecnt + 1;
    imu_filename = string.format(imu_filepath.."/log-imu-%s-%d", imu_filetime, imu_filecnt);
    imu_file = io.open(imu_filename, "w");
  end
  if gps_linecount >= maxlinecount and fileSaveFlag then
    gps_linecount = 0;
    gps_file:close();
    gps_filecnt = gps_filecnt + 1;
    gps_filename = string.format(gps_filepath.."/log-gps-%s-%d", gps_filetime, gps_filecnt);
    gps_file = io.open(gps_filename, "w");
  end
  if mag_linecount >= maxlinecount and fileSaveFlag then
    mag_linecount = 0;
    mag_file:close();
    mag_filecnt = mag_filecnt + 1;
    mag_filename = string.format(mag_filepath.."/log-mag-%s-%d", mag_filetime, mag_filecnt);
    mag_file = io.open(mag_filename, "w");
  end
  if label_linecount >= maxlinecount and fileSaveFlag then
    label_linecount = 0;
    label_file:close();
    label_filecnt = label_filecnt + 1;
    label_filename = string.format(label_filepath.."/log-label-%s-%d", label_filetime, label_filecnt);
    label_file = io.open(label_filename, "w");
  end
end

