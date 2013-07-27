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

function clean_data(data, start_time, end_time, section_time)
    local data_clean = {}
    for i = 1, #data do
        data_time = data[i].timestamp or data[i].timstamp
        local datavalid = false
        if data_time >= start_time and data_time <= end_time then
            datavalid = true
        end
        for j = 1, #section_time do
            local section = section_time[j]
            if data_time >= section[1] and data_time <= section[2] then
                print('clean middle points')
                datavalid = false
            end
        end
        if datavalid then
            data_clean[#data_clean+1] = data[i]
        end
    end
    print('Clean Data with timestamp')
    print('previous size '..#data, 'current size '..#data_clean)
    return data_clean
end

--local datasetpath = '../data/010213192135.40/'
local datasetpath = '../data/philadelphia/260713145217.80/'
--local datasetpath = './'
package.path = datasetpath..'?.lua;'..package.path
--local prediction = loadDataMP(datasetpath, 'estimateMP', _, 1)
--local gps = loadDataMP(datasetpath, 'gpsMP', _, 1)
local label = loadDataMP(datasetpath, 'labelPrunedMP', _, 1)
--local imu = loadDataMP(datasetpath, 'imuPrunedMP', _, 1)
--local mag = loadDataMP(datasetpath, 'magPrunedMP', _, 1)

--print(findDateFromGPS(gps))

--require 'params'
--print(start_time, end_time)
--saveDataMP(clean_data(gps, start_time, end_time, section_time), 'gpsLocalCleanMP', './')
--saveDataMP(clean_data(label, start_time, end_time, section_time), 'labelCleanMP', './')
--saveDataMP(clean_data(imu, start_time, end_time, section_time), 'imuPrunedCleanMP', './')
--saveDataMP(clean_data(mag, start_time, end_time, section_time), 'magPrunedCleanMP', './')
--print(#gps, #label, #prediction)
--saveCSV(gps, 'gps-csv', './')

print(#label)
local label_pruned = {}
for i = 1, #label do
  if i ~= 29 and i ~= 30 and i ~= 33 then
    label_pruned[#label_pruned + 1] = label[i]
  end
end
print(#label_pruned)
saveDataMP(label_pruned, 'labelPrunedMP', './')
