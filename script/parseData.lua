-- parse data file and save as xml

require 'include'

local serialization = require 'serialization'

require 'parseIMU'
require 'parseGPS'
require 'parseMAG'
require 'parseLAB'
require 'common'

dataPath = '../data/8/'
dataStamp = '01010000'
--dataStamp = '01010122'


imuset = parseIMU()
saveData(imuset, 'imu')
--print(#imuset)

gpsset = parseGPS()
saveData(gpsset, 'gps')
--print(#gpsset)

magset = parseMAG()
saveData(magset, 'mag')
--print(#magset)
--
labelset = parseLAB()
saveData(labelset, 'label')
--print(#labelset)


