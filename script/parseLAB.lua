require 'include'
local util = require 'util'

function readLabelLine(str, len)
  local label = {}
  label.timstamp = tonumber(string.sub(str, 1, 16))
  
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
        if datacheck and util.tablesize(label) > 1 then
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

function parseLAB()
  local data = loadData(dataPath, dataStamp, 'lab')
  labelset = iterateLAB(data)

  return labelset
end


