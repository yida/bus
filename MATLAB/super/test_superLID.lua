module(... or '', package.seeall)

-- Add the required paths
cwd = '.';

uname  = io.popen('uname -s')
system = uname:read();

package.cpath = cwd.."/?.so;"..package.cpath;
package.cpath = cwd.."/../../../UPennDev/Player/Lib/?.so;"..package.cpath;
package.path = cwd.."/../../../UPennDev/Player/Util/?.lua;"..package.path;
package.path = cwd.."/../../../UPennDev/Player/Config/?.lua;"..package.path;
package.path = cwd.."/../../../UPennDev/Player/Vision/?.lua;"..package.path;

require('serialization');
require('Hokuyo')
require('signal')
require('Serial');
require('kBPacket');
require('unix');
require('rcm');

hokuyo = {}
hokuyo.serial = "00805676"
--hokuyo.serial = "00907258"
hokuyo.device = "/dev/ttyACM0"
Hokuyo.open(hokuyo.device, hokuyo.serial);


function ShutDownFN()
  print("Proper shutdown")
  Hokuyo.shutdown()
  os.exit(1);
end

-- Create files
lidarfilecnt = 0;
filetime = os.date('%m.%d.%Y.%H.%M');
filename = string.format("lidar%s-%d", filetime, lidarfilecnt);

file = io.open(filename, "w");
linecount = 0;
maxlinecount = 1000;



cntr = 0;
cnti = 0;
t0 = unix.time();
t2 = unix.time();
while (1) do
  t1 = unix.time(); -- timestamp

  Hokuyo.update();
  cntr = cntr + 1;
  if (cntr % 40 == 0) then
    print("Scan rate "..40/(unix.time() - t0));
    t0 = unix.time();
  end

  lidar = Hokuyo.retrieve();
  width = rcm.nReturns;
  height = 1;
  lidarArray = serialization.serialize_array(lidar.ranges, width,
                height, 'single', 'ranges', lidar.counter);
  savelidar = {};
  savelidar.timestamp = t1;
  savelidar.arr = lidarArray[1];
  local savedata=serialization.serialize(savelidar);
--  print(savedata);
--  savedata = Z.compress(savedata, #savedata);
  file:write(savedata);
  file:write('\n');
  linecount = linecount + 1;
  if linecount > maxlinecount then
    linecount = 0;
    file:close();
    lidarfilecnt = lidarfilecnt + 1;
    filename = string.format("lidar%s-%d", filetime, lidarfilecnt);
    file = io.open(filename, "w");
  end

  signal.signal("SIGINT", ShutDownFN);
  signal.signal("SIGTERM", ShutDownFN);

end

file:close();

