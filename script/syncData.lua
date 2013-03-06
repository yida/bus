
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

local datasetpath = '../data/211212164337/'

set1 = loadData(datasetpath, 'imuPruned')
--mag = loadData(datasetpath, 'magPruned')
set2 = loadData(datasetpath, 'magPruned')
set3 = loadData(datasetpath, 'gps')
--label = loadData(datasetpath, 'label')

data = syncData(_, set1, set2)
data = syncData(_, data, set3)

--print(#mag, #imu, #data)
--saveData(LabelwGPS, 'labelgps')
--saveData(data, 'imugps')
saveData(data, 'imugpsmag')


----saveData(data, 'syncdlabelgps')
--
--LabelwGPS = {}
--LabelwGPScounter = 0
---- search closest GPS stamp for every label
--for cnt = 1, #data do
--  if data[cnt].type == 'label' then
----    print(cnt) 
--    local leftclosegps = cnt
--    local rightclosegps = cnt
--
--    for i = cnt - 1, 1, -1 do
--      if data[i].type == 'gps' and data[i].latitude ~= nil then
--        leftclosegps = i break
--      end
--    end
--    for i = cnt + 1, #data, 1 do
--      if data[i].type == 'gps' and data[i].latitude ~= nil then
--        rightclosegps = i break
--      end
--    end
--    local leftTimeDiff = data[cnt].timstamp - data[leftclosegps].timstamp
--    local rightTimeDiff = data[rightclosegps].timstamp - data[cnt].timstamp
--    if leftTimeDiff < rightTimeDiff then 
--      LabelwGPScounter = LabelwGPScounter + 1
--      LabelwGPS[LabelwGPScounter] = data[leftclosegps]
--      LabelwGPS[LabelwGPScounter].value = data[cnt].value
--      print(data[leftclosegps].latitude) 
--    else 
--      LabelwGPScounter = LabelwGPScounter + 1
--      LabelwGPS[LabelwGPScounter] = data[rightclosegps]
--      LabelwGPS[LabelwGPScounter].value = data[cnt].value      
--      print(data[rightclosegps].latitude) 
--    end
--  end  
--end
--
--while true do
--end
