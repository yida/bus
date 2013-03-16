require 'ucm'

require 'include'
require 'common'
require 'poseUtils'
require 'torch-load'
require 'GPSparser'
require 'GPSUtils'

local serialization = require('serialization');


local datasetpath = '../data/'
--local dataset = loadData(datasetpath, 'observation', _, 1)
local dataset = loadData(datasetpath, 'log-946684834.', _, 1)

local counter = 0
local labelcounter = 0
local imu = {}
local mag = {}
local gps = {}
local label = {}
for i = 1, #dataset do
  if dataset[i].type == 'imu' then
    imu[#imu+1] = dataset[i]
  elseif dataset[i].type == 'mag' then
    mag[#mag+1] = dataset[i]
  elseif dataset[i].type == 'gps' then
    if gpsChecksum(dataset[i].line) then
      gpsContent = readGPSLine(dataset[i].line, #dataset[i].line, 1)
      gpsContent.timestamp = dataset[i].timestamp
      gpsContent.timstamp = nil
      gps[#gps+1] = gpsContent
    end
  elseif dataset[i].type == 'label' then
    label[#label+1] = dataset[i]
  end
end

saveDataMP(gps, 'gpsMP', './')
saveDataMP(imu, 'imuPrunedMP', './')
saveDataMP(mag, 'magPrunedMP', './')
saveDataMP(label, 'labelMP', './')
