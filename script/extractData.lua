--require 'ucm'

require 'include'
require 'common'
require 'poseUtils'
require 'GPSparser'
require 'GPSUtils'

--local serialization = require('serialization');

local datasetpath = '../data/rawdata/'
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
--        if dataset[i].line:find('$GPGGA') or dataset[i].line:find('$GPRMC') then
--          print(dataset[i].line)
--        end
        gpsContent = readGPSLine(dataset[i].line, #dataset[i].line, 1)
        local datavalid = true
        if gpsContent.id == 'GLL' or gpsContent.id == 'RMC' then 
          if gpsContent.status == 'V' then
            print(gpsContent.id, gpsContent.status) 
            datavalid = false
          end
        end
        if gpsContent.id == 'GGA' then 
          if gpsContent.quality ~= '1' and gpsContent.quality ~= '2' then
            datavalid = false
            print(gpsContent.id, gpsContent.quality) 
          end
        end
        if gpsContent.id == 'GSA' then 
          if gpsContent.navMode == '1' or gpsContent.navMode == '2' then
            datavalid = false
            print(gpsContent.id, gpsContent.navMode) 
          end
        end
        if gpsContent.id == 'GLL'  or gpsContent.id == 'RMC' or gpsContent.id == 'VTG' then
          if gpsContent.posMode ~= 'A' and gpsContent.posMode ~= 'D' then
            datavalid = false
            print(gpsContent.id, gpsContent.posMode) 
          end
        end
        if gpsContent.utctime == '' then
          datavalid = false
--          print('invalid ', gpsContent.id)
        end
        if datavalid then 
          print(gpsContent.id)
          gpsContent.timestamp = dataset[i].timestamp
          gpsContent.timstamp = nil
          gps[#gps+1] = gpsContent
        end
      end
    elseif dataset[i].type == 'label' then
      label[#label+1] = dataset[i]
    end
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

saveDataMP(gps, 'gpsMP', './'..prefix)
--saveDataMP(imu, 'imuPrunedMP', './'..prefix)
--saveDataMP(mag, 'magPrunedMP', './'..prefix)
--saveDataMP(label, 'labelMP', './'..prefix)
