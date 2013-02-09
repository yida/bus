
require 'include'
local serialization = require 'serialization'

function checkLen(value, len)
  if len == value then
    return true
  else
    return false
  end
end

function loadRawData(path, stamp, datatype)
  local data = {}
  data.Path = path
  data.Stamp = stamp
  data.Type = datatype
  data.Name = data.Path..data.Type..data.Stamp..'*'
  data.FileList = assert(io.popen('/bin/ls '..data.Name, 'r'))
  data.FileNum = 0
  for lines in data.FileList:lines() do data.FileNum = data.FileNum + 1 end
  return data
end

function saveData(dataset, dtype)
  local filecnt = 0
  local filetime = os.date('%m.%d.%Y.%H.%M.%S')
  local filename = string.format(dtype.."-%s-%d", filetime, filecnt)
  
  local file = io.open(filename, "w")
  
  print(#dataset)
  for i = 1, #dataset do
    io.write('\rline #'..i)
    savedata = serialization.serialize(dataset[i])
    file:write(savedata)
    file:write('\n')
  --  print(savedata)
  end
  io.write('\n')
  file:close()
  print(filename)
end

function getFileName(path, dtype)
  local file = assert(io.popen('/bin/ls '..path..dtype..'-*', 'r'))
  local filename = file:read();
  return filename
end

function loadData(path, dtype, maxlines)
  local filename = getFileName(path, dtype)
  local file = assert(io.open(filename, 'r+'))
  local line = file:read();
  local datacounter = 0
  local data = {}
  while line ~= nil do
--    print(line)
    datacounter = datacounter + 1
    io.write('\r', dtype, datacounter)
    dataPoint = serialization.deserialize(line)
    data[datacounter] = dataPoint
--    util.ptable(dataPoint)
    line = file:read();
    if maxlines and datacounter >= maxlines then break end
  end
  io.write('\n')
  print(filename)
  return data
end


function pruneTUC(set) -- select the first tuc imu
  local lastTuc = 0
  local Pruned = {}
  local Prunedcount = 0
  for i = 1, #set do
    if set[i].tuc ~= lastTuc then
      lastTuc = set[i].tuc
      Prunedcount = Prunedcount + 1
      Pruned[Prunedcount] = set[i]
    end
  end
  return Pruned
end
