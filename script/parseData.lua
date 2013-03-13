-- parse data file and save as xml

require 'include'

local serialization = require 'serialization'

require 'IMUparser'
require 'GPSparser'
require 'MAGparser'
require 'LABparser'
require 'common'

--dataPath = '../data/rawdata/20121221route42/'
dataPath = '../data/rawdata/8/'
dataStamp = '01010000'
--dataStamp = '01010122'
--dataStamp = '12311916'


--imuset = parseIMU()
--saveData(imuset, 'imu')
----print(#imuset)

gpsset = parseGPS()
saveData(gpsset, 'gps', './')
for i = 1, #gpsset do
--  if gpsset[i].HDOP ~= nil then
--    print('HDOP '..gpsset[i].HDOP)
--  end
--  if gpsset[i].VDOP ~= nil then
--    print('VDOP '..gpsset[i].VDOP)
--  end
  if gpsset[i].satellites ~= nil then
    print('VDOP '..gpsset[i].satellites)
  end

end
--print(#gpsset)

--magset = parseMAG()
--saveData(magset, 'mag')
------print(#magset)
----
--labelset = parseLAB()
--saveData(labelset, 'label')
--------print(#labelset)


