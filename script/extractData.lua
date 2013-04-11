require 'include'
require 'common'
require 'poseUtils'
require 'GPSparser'
require 'GPSUtils'

local datasetpath = '../data/rawdata/'
--local datasetpath = '../simulation/'
--local dataset = loadData(datasetpath, 'observation', _, 1)
local dataset = loadData(datasetpath, 'log-946684834.63068', _, 1)

function extractFromLog(dataset)
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
        local datavalid = gpsDataCheck(gpsContent)
        if datavalid then 
          gpsContent.timestamp = dataset[i].timestamp
          gpsContent.timstamp = nil
          gps[#gps+1] = gpsContent
        end
      end
    elseif dataset[i].type == 'label' then label[#label+1] = dataset[i] end
  end
  return imu, mag, gps, label
end

imu, mag, gps, label = extractFromLog(dataset)

local prefix = ''
if gps ~= {} then
  prefix = findDateFromGPS(gps)
  prefix = prefix..'/'
end
print(prefix)
prefix = ''

print(#gps)
saveDataMP(gps, 'gpsMP', './'..prefix)
saveDataMP(imu, 'imuPrunedMP', './'..prefix)
saveDataMP(mag, 'magPrunedMP', './'..prefix)
saveDataMP(label, 'labelMP', './'..prefix)
