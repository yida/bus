dofile('include.lua')

require 'common'
require 'poseUtils'
require 'GPSUtils'
local torch = require 'torch'
local util = require 'util'

function applylabel(prediction, gps)
  local idx_predict = 1
  for i = 1, #gps do
    while idx_predict < #prediction and prediction[idx_predict].timestamp <= gps[i].timestamp do
      idx_predict = idx_predict + 1
    end
    gps[i].predict = prediction[idx_predict-1].predict or 3
  end
end

function clean_data(data, start_time, end_time)
    local data_clean = {}
    for i = 1, #data do
        if data[i].timestamp >= start_time and data[i].timestamp <= end_time then
            data_clean[#data_clean+1] = data[i]
        end
    end
    print('Clean Data with timestamp')
    print('previous size '..#data, 'current size '..#data_clean)
    return data_clean
end

local datasetpath = '../data/150213185940.20/'
package.path = datasetpath..'?.lua;'..package.path
require 'params'
--local prediction = loadDataMP(datasetpath, 'estimateMP', _, 1)
local gps = loadDataMP(datasetpath, 'gpsLocalMP', _, 1)
local label = loadDataMP(datasetpath, 'labelMP', _, 1)
local imu = loadDataMP(datasetpath, 'imuPrunedMP', _, 1)
local mag = loadDataMP(datasetpath, 'magPrunedMP', _, 1)

print(start_time, end_time)
saveDataMP(clean_data(gps, start_time, end_time), 'gpsLocalCleanMP', './')
saveDataMP(clean_data(label, start_time, end_time), 'labelCleanMP', './')
saveDataMP(clean_data(imu, start_time, end_time), 'imuPrunedCleanMP', './')
saveDataMP(clean_data(mag, start_time, end_time), 'magPrunedCleanMP', './')
--print(#gps, #label, #prediction)
