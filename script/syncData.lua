
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
    time1 = set1[set1counter].timstamp or set1[set1counter].timestamp
    time2 = set2[set2counter].timstamp or set2[set2counter].timestamp
    if (time1 < time2) then
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
      data[datacounter] = set1[cnt]
    end
  end
  
  -- push rest of set2
  if set2counter < #set2 then
    for cnt = set2counter, #set2 do
      datacounter = datacounter + 1
      data[datacounter] = set2[cnt]
    end
  end

  return data
end

--local datasetpath = '../data/010213192135/'
local datasetpath = '../data/150213185940/'
--local datasetpath = '../data/191212190259/'
--local datasetpath = '../data/211212164337/'
--local datasetpath = '../data/211212165622/'
--local datasetpath = '../data/010213180247/'
--imu = loadData(datasetpath, 'imuPruned', _, 1)
--mag = loadData(datasetpath, 'magPruned', _, 1)
--gps = loadData(datasetpath, 'gpsLocal', _, 1)
--label = loadData(datasetpath, 'label')
--data = syncData(_, imu, gps)
--data = syncData(_, data, mag)
--saveData(data, 'measurement', datasetpath)

state = loadData(datasetpath, 'state150213185940', _, 1)
label = loadData(datasetpath, 'label', _, 1)
data = syncData(_, state, label)
------print(#mag, #imu, #data)
saveData(data, 'observation')


----saveData(data, 'syncdlabelgps')

