require 'ucm'

require 'include'
require 'common'
require 'poseUtils'
require 'torch'
require 'GPSUtils'

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

