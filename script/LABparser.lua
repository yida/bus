require 'include'
local util = require 'util'

function readLabelLine(str, len)
  local label = {}
  label.timstamp = tonumber(string.sub(str, 1, 16))
  label.type = 'label'
  local value = string.sub(str, 18, 21)
  if value ~= "0000" then
--    print(value)
    label.value = value
  end

  return label;
end

function iterateLAB(data)
  local labelset = {}
  local labelcounter = 0
--  for i = 0, 0 do -- data.FileNum - 1 do
  for i = 0, data.FileNum - 1 do
    local fileName = data.Path..data.Type..data.Stamp..i
    print(fileName)
    local file = assert(io.open(fileName, 'r+'))
    local line = file:read("*all");
    local lfpos = string.find(line, '\n', 1)
    local lastlfpos = 0;
    while lfpos ~= nil do
      local substr = string.sub(line, lastlfpos + 1, lfpos)
      --print(substr)
      --print(string.byte(substr, 1, lfpos - lastlfpos)) 
      local len = lfpos - lastlfpos - 1 
      local lencheck = checkLen(21, len)
      if lencheck then
        label = readLabelLine(substr, len)
        local datacheck = checkData(label)
        if datacheck and util.tablesize(label) > 2 then
          local tdata = os.date('*t', label.timestamp)
--          print(label.timstamp, tdata.year, tdata.month, tdata.day, tdata.hour, tdata.min, tdata.sec)
          labelcounter = labelcounter + 1
          labelset[labelcounter] = label
        else
--          print('datecheck fail')
        end
      else
--        print('lencheck fail '..len)
      end
      lastlfpos = lfpos
      lfpos = string.find(line, '\n', lfpos + 1)
    end
    file:close();
  end
  return labelset

end


function readLabelFromIMU(str, len)
  local label = {}
  label.type = 'label'
  label.timstamp = tonumber(string.sub(str, 1, 16))
  local value = str:sub(17,18)
  if value == '10' or value == '01' then
    label.value = value
    print(label.value)
  end
  return label
end


function iterateLabFromIMU(data)
  local labelset = {}
  local labelcounter = 0
--  for i = 0, 0 do -- data.FileNum - 1 do
  for i = 0, data.FileNum - 1 do
    local fileName = data.Path..data.Type..data.Stamp..i
    print(fileName)
    local file = assert(io.open(fileName, 'r+'))
    local line = file:read("*all");
    local lfpos = string.find(line, '\n', 1)
    local lastlfpos = 0;
    while lfpos ~= nil do
      local substr = string.sub(line, lastlfpos + 1, lfpos)
      --print(substr)
      --print(string.byte(substr, 1, lfpos - lastlfpos)) 
      local len = lfpos - lastlfpos - 1 
      local lencheck = checkLen(44, len) or checkLen(40, len) or checkLen(42, len)
--      print(len, lencheck)
      if lencheck then
        label = readLabelFromIMU(substr, len) 
        local datacheck = checkData(label)
        if datacheck and util.tablesize(label) > 2 then
--          local tdata = os.date('*t', imu.timestamp)
--          print(imu.timstamp, imu.tuc, imu.r, imu.p, imu.y, imu.wr, imu.wp, imu.wy, imu.ax, imu.ay, imu.az)
--          print(imu.timstamp, tdata.year, tdata.month, tdata.day, tdata.hour, tdata.min, tdata.sec)
          labelcounter = labelcounter + 1
          labelset[labelcounter] = label
        else
--        print('datecheck fail')
        end
      else
--      print('lencheck fail '..len)
      end
      lastlfpos = lfpos
      lfpos = string.find(line, '\n', lfpos + 1)
    end
    file:close();
  end
  return labelset

end

function parseLAB()
  local data = loadRawData(dataPath, dataStamp, 'lab')
  labelset = iterateLAB(data)
--  local data = loadRawData(dataPath, dataStamp, 'imu')
--  labelset = iterateLabFromIMU(data)

  return labelset
end


