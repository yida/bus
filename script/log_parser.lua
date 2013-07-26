
dofile('include.lua')

require 'IMUparser'
require 'GPSparser'
require 'MAGparser'
require 'LABELparser'

require 'common'

datapath = '../data/rawlog/'

--dataStamp = '072620130941'
--dataStamp = '072620131027'
--dataStamp = '072620131052'
dataStamp = '072620131134'

function load_log_data(path, stamp, datatype)
  local data = {}
  data.Path = path
  data.Stamp = stamp
  data.Type = datatype
  data.Name = data.Path..'log-'..data.Type..'-'..data.Stamp..'-*'
  data.FileList = assert(io.popen('/bin/ls '..data.Name, 'r'))
  data.FileNum = 0
  for lines in data.FileList:lines() do data.FileNum = data.FileNum + 1 end
  return data
end

local ts_pattern = '%d%d%d%d%d%d%d%d%d%d%.%d%d%d%d%d%d'
function iterate_log(data, size_limit)
  local set = {}
  for file_cnt = 0, data.FileNum - 1 do
    local filename = data.Name:sub(1, #data.Name - 1)..file_cnt
    print(filename)
    local file = io.open(filename, 'r')
    local file_str = file:read('*a')
    local lastlfpos = string.find(file_str, ts_pattern, 1)
    if not lastlfpos then break end
    local lfpos = string.find(file_str, ts_pattern, lastlfpos + 1)
    while lfpos do
      local sample_str = file_str:sub(lastlfpos, lfpos - 1)
      if #sample_str >= size_limit then
        value, label = _G['read'..data.Type:upper()..'Line'](sample_str, 17, 0)
        set[#set + 1] = value
      end
      lastlfpos = lfpos
      lfpos = string.find(file_str, ts_pattern, lastlfpos + 1)
    end
    file:close()
  end
  return set
end

imu_data_file = load_log_data(datapath, dataStamp, 'imu')
imu_set = iterate_log(imu_data_file, 41)
print(#imu_set)
saveDataMP(imu_set, 'imuPrunedMP', './')

gps_data_file = load_log_data(datapath, dataStamp, 'gps')
gps_set = iterate_log(gps_data_file, 0)
print(#gps_set)
saveDataMP(gps_set, 'gpsMP', './')

mag_data_file = load_log_data(datapath, dataStamp, 'mag')
mag_set = iterate_log(mag_data_file, 36)
print(#mag_set)
saveDataMP(mag_set, 'magPrunedMP', './')

label_data_file = load_log_data(datapath, dataStamp, 'label')
label_set = iterate_log(label_data_file, 21)
print(#label_set)
saveDataMP(label_set, 'labelPrunedMP', './')

