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

--local datasetpath = '../data/philadelphia/010213180304.00/'
local datasetpath = '../data/philadelphia/150213185940.20/'
--local datasetpath = '../data/philadelphia/260713145217.80/'
--local datasetpath = './'
package.path = datasetpath..'?.lua;'..package.path
--local prediction = loadDataMP(datasetpath, 'estimateMP', _, 1)
--local gps = loadDataMP(datasetpath, 'gpsMP', _, 1)
--local gpsLocal = loadDataMP(datasetpath, 'gpsLocalMP', _, 1)
--local label = loadDataMP(datasetpath, 'labelMP', _, 1)
local labelPruned = loadDataMP(datasetpath, 'labelPrunedMP', _, 1)
--local imu = loadDataMP(datasetpath, 'imuMP', _, 1)
--local imuPruned = loadDataMP(datasetpath, 'imuPrunedMP', _, 1)
--local mag = loadDataMP(datasetpath, 'magMP', _, 1)
--local magPruned = loadDataMP(datasetpath, 'magPrunedMP', _, 1)

time = {946684970.550000, 946685185.550000}

function clean_time_data(data, time, str, debug)
  print(str..' '..#data)
  local data_clean = {}

  for i = 1, #data do 
    if data[i].timestamp == nil then
      data[i].timestamp = data[i].timstamp
      data[i].timstamp = nil
    end

    if debug then
      util.ptable(data[i])
    end
    if data[i].timestamp <= time[2] and data[i].timestamp >= time[1] then
      data_clean[#data_clean + 1] = data[i]
    end
  end
  return data_clean
end

--saveDataMP(clean_time_data(gps, time, 'gps'), 'gpsMP', './')
--saveDataMP(clean_time_data(gpsLocal, time, 'gpsLocal'), 'gpsLocalMP', './')
--saveDataMP(clean_time_data(label, time, 'label'), 'labelMP', './')
saveDataMP(clean_time_data(labelPruned, time, 'labelPruned'), 'labelPrunedMP', './')
----saveDataMP(clean_time_data(imu, time, 'imu'), 'imuMP', './')
--saveDataMP(clean_time_data(imuPruned, time, 'imuPruned'), 'imuPrunedMP', './')
----saveDataMP(clean_time_data(mag, time, 'mag'), 'magMP', './')
--saveDataMP(clean_time_data(magPruned, time, 'magPruned'), 'magPrunedMP', './')

--print(findDateFromGPS(gps))

--require 'params'
--print(start_time, end_time)
--saveDataMP(clean_data(gps, start_time, end_time, section_time), 'gpsLocalCleanMP', './')
--saveDataMP(clean_data(label, start_time, end_time, section_time), 'labelCleanMP', './')
--saveDataMP(clean_data(imu, start_time, end_time, section_time), 'imuPrunedCleanMP', './')
--saveDataMP(clean_data(mag, start_time, end_time, section_time), 'magPrunedCleanMP', './')
--print(#gps, #label, #prediction)
--saveCSV(gps, 'gps-csv', './')
--saveDataMP(label_pruned, 'labelPrunedMP', './')

