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

--[[
imuset = parseIMU()
saveDataMP(imuset, 'imuMP', './')
print 'prune imu'
imusetPruned = pruneTUC(imuset)
saveDataMP(imusetPruned, 'imuPrunedMP', './')
print(#imuset)
--]]
--
gpsset = parseGPS()
if #gpsset > 0 then
  saveDataMP(gpsset, 'gpsMP', './')
  print(#gpsset)
end
--
--[[
collectgarbage()
magset = parseMAG()
saveDataMP(magset, 'mag', './')
print 'prune mag'
magsetPruned = pruneTUC(magset)
saveDataMP(magsetPruned, 'magPrunedMP', './')
print(#magset)
collectgarbage()
------
labelset = parseLAB()
saveDataMP(labelset, 'labelMP', './')
print(#labelset)
-]]

