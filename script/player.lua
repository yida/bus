require 'include'
require 'common'
require 'poseUtils'
require 'GPSUtils'
local torch = require 'torch'
local util = require 'util'

local datasetpath = '../data/010213180304.00/'
--local imu = loadDataMP(datasetpath, 'imuPrunedMP', _, 1)
--local gps = loadDataMP(datasetpath, 'gpsMP', _, 1)
local label = loadDataMP(datasetpath, 'labelMP', _, 1)


local datasetpath = '../data/010213180304.00/'
local prediction = loadDataMP(datasetpath, 'estimateMP', _, 1)
local gps = loadDataMP(datasetpath, 'gpsLocalMP', _, 1)
local label = loadDataMP(datasetpath, 'labelMP', _, 1)

for i = 1, #label do
  print(label[i].value)
end

--print(#prediction, #gps)
--print(prediction[#prediction].timestamp, gps[#gps].timestamp)
function applylabel(prediction, gps)
  local idx_predict = 1
  for i = 1, #gps do
    while idx_predict < #prediction and prediction[idx_predict].timestamp <= gps[i].timestamp do
      idx_predict = idx_predict + 1
    end
  --  print(idx_predict)
  --  print(prediction[idx_predict].timestamp, 
  --        prediction[idx_predict-1].timestamp, gps[i].timestamp) 
    gps[i].predict = prediction[idx_predict-1].predict or 3
  end
end

--[[
saveDataMP(gps,'gpsEstimateMP', datasetpath)
for i = 1, #gps do
  print(gps[i].predict)
end

saveCSV(gps, 'estimate-csv', datasetpath)
local pre = loadDataMP(datasetpath, 'gpsEstimateMP', _, 1)

print(#pre)
--]]
