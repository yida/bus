-- parse data file and save as xml

require 'parseIMU'

dataPath = '../data/1/'
dataStamp = '01010000'

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

function parseGPS()
  local data = loadData(dataPath, dataStamp, 'gps')
  print(data.FileNum)
end

function parseMAG()
  local data = loadData(dataPath, dataStamp, 'mag')
  print(data.FileNum)
end

function parseLAB()
  local data = loadData(dataPath, dataStamp, 'lab')
  print(data.FileNum)
end



parseIMU()
--parseGPS()
--parseMAG()
--parseLAB()
