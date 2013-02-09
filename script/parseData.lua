-- parse data file and save as xml

require 'include'

local serialization = require 'serialization'

require 'parseIMU'
require 'parseGPS'
require 'parseMAG'
require 'parseLAB'
require 'common'

dataPath = '../data/rawdata/20121221route42/'
dataStamp = '01010000'
--dataStamp = '01010122'
dataStamp = '12311916'


imuset = parseIMU()
saveData(imuset, 'imu')
--print(#imuset)

gpsset = parseGPS()
saveData(gpsset, 'gps')
--print(#gpsset)

magset = parseMAG()
saveData(magset, 'mag')
----print(#magset)
--
labelset = parseLAB()
saveData(labelset, 'label')
------print(#labelset)


