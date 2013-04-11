require 'include'
require 'common'
require 'poseUtils'
require 'torch'
require 'GPSUtils'
local util = require 'util'

local datasetpath = '../data/150213185940.20/'
--local datasetpath = '../data/010213180247/'
--local datasetpath = './'
--local dataset = loadDataMP(datasetpath, 'labelMP', _, 1)
--
--local newdataset = {}
--local i = 1
--while i <= #dataset do
----for i = 1, #dataset do
--  if dataset[i].type == 'label' then
--    if dataset[i].timestamp > 946686893.57 and dataset[i].timestamp < 946686897.74 then
--      print(dataset[i].timestamp, dataset[i].value)
--    else
--      newdataset[#newdataset+1] = dataset[i]
--    end 
--  end
--  i = i + 1
--end
--
--print(#newdataset)
--saveDataMP(newdataset, 'labelCleanMP', datasetpath)
local dataset = loadDataMP(datasetpath, 'imuwlabelBinaryMP', _, 1)
--local dataset = loadDataMP(datasetpath, 'labelMP', _, 1)

for i = 1, #dataset do
  if dataset[i].label ~= 3 then
    print(dataset[i].label)
  end
--  if dataset[i].value:find('1000') then
--    dataset[i].num = 1
--    print(dataset[i].timestamp, 1)
--  elseif dataset[i].value:find('0100') then
--    dataset[i].num = 2
--    print(dataset[i].timestamp, 2)
--  elseif dataset[i].value:find('0010') then
--    dataset[i].num = 3
--    print(dataset[i].timestamp, 3)
--  elseif dataset[i].value:find('0001') then
--    dataset[i].num = 4
--    print(dataset[i].timestamp, 4)
--  end
end

saveDataMP(dataset, 'labelnumMP', datasetpath)
