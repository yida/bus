-- parse data file and save as xml

require 'include'
local serialization = require 'serialization'
local util = require 'util'

require 'parseIMU'
require 'parseGPS'
require 'parseMAG'
require 'parseLAB'

dataPath = '../data/7/'
dataStamp = '01010000'
--dataStamp = '01010122'

function loadData(path, stamp, datatype)
  local data = {}
  data.Path = path
  data.Stamp = stamp
  data.Type = datatype
  data.Name = data.Path..data.Type..data.Stamp..'*'
  data.FileList = assert(io.popen('/bin/ls '..data.Name, 'r'))
  data.FileNum = 0;
  for lines in data.FileList:lines() do data.FileNum = data.FileNum + 1; end
  return data
end

function saveData(dataset, dtype)
  filecnt = 0;
  filetime = os.date('%m.%d.%Y.%H.%M.%S');
  filename = string.format(dtype.."-%s-%d", filetime, filecnt);
  
  file = io.open(filename, "w");
  
  print(#dataset)
  for i = 1, #dataset do
    print('line #'..i)
    savedata = serialization.serialize(dataset[i])
    file:write(savedata)
    file:write('\n')
  --  print(savedata)
  end
  file:close()
  print(filename)
end


imuset = parseIMU()
saveData(imuset, 'imu')
--print(#imuset)

gpsset = parseGPS()
saveData(gpsset, 'gps')
--print(#gpsset)

magset = parseMAG()
saveData(magset, 'mag')
--print(#magset)
--
labelset = parseLAB()
saveData(labelset, 'label')
--print(#labelset)


