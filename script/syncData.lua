
require 'include'
require 'common'

local serialization = require 'serialization'
local util = require 'util'

-- sync and merge
local data = {}
function syncData(data, set1, set2)
  local data = data or {}
  local datacounter = 0
  local set1counter = 1
  local set2counter = 1

  -- select early time stamp and push to data
  while set1counter <= #set1 and set2counter <= #set2 do 
    datacounter = datacounter + 1
    if (set1[set1counter].timstamp < set2[set2counter].timstamp) then
      data[datacounter] = set1[set1counter]
      set1counter = set1counter + 1
    else
      data[datacounter] = set2[set2counter]
      set2counter = set2counter + 1
    end
  end
  
  -- push rest of set1
  if set1counter < #set1 then
    for cnt = set1counter, #set1 do
      datacounter = datacounter + 1
      data[datacounter] = set1[set1counter]
    end
  end
  
  -- push rest of set2
  if set2counter < #set2 then
    for cnt = set2counter, #set2 do
      datacounter = datacounter + 1
      data[datacounter] = set2[set2counter]
    end
  end

  return data
end

local datasetpath = '../data/dataset9/'

--imu = loadData(datasetpath, 'imu')
--mag = loadData(datasetpath, 'mag')
gps = loadData(datasetpath, 'gps')
label = loadData(datasetpath, 'label')

data = syncData(_, gps, label)

print(#gps, #label, #data)
saveData(data, 'syncdlabelgps')

-- search closest GPS stamp for every label
for cnt = 1, #data do
end

--while true do
--end
