-- parse data file and save as xml

dofile('include.lua')

local serialization = require 'serialization'

require 'IMUparser'
require 'GPSparser'
require 'MAGparser'
require 'LABparser'
require 'common'

--dataPath = '../data/rawdat/20121221route42/'
--dataPath = '../data/rawdata/8/'
--dataPath = '../data/rawdata/9/'
dataPath = '../data/rawdata/2012121914/'
--dataStamp = '01010000'
--dataStamp = '01010122'
--dataStamp = '12311916'
dataStamp = '12311901'

--[[
imuset = parseIMU(2)
if #imuset > 0 then
  saveDataMP(imuset, 'imuMP', './')
  print 'prune imu'
  imusetPruned = pruneTUC(imuset)
  if #imusetPruned > 0 then
    saveDataMP(imusetPruned, 'imuPrunedMP', './')
    print(#imuset)
  else
    print("imu pruned set empty!")
  end
else
  print("imu set empty!")
end
--]]
--[[
gpsset = parseGPS()
if #gpsset > 0 then
  saveDataMP(gpsset, 'gpsMP', './')
  print(#gpsset)
end
--]]
--[[
magset = parseMAG()
saveDataMP(magset, 'mag', './')
print 'prune mag'
magsetPruned = pruneTUC(magset)
saveDataMP(magsetPruned, 'magPrunedMP', './')
print(#magset)
--]]
------

labelset = parseLAB(true, 'imu')
saveDataMP(labelset, 'labelMP', './')
print(#labelset)


