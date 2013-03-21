local ucm = require 'ucm'

require 'include'
require 'common'
require 'poseUtils'
require 'torch'
local util = require 'util'

local datasetpath = '../data/150213185940.20/'
--local datasetpath = '../data/010213180247/'
--local dataset = loadDataMP(datasetpath, 'imuPrunedMP', _, 1)
local dataset = loadDataMP(datasetpath, 'labelMP', _, 1)

lastT = dataset[1].timestamp
for i = 1, #dataset do
  if dataset[i].type == 'imu' then
    print(dataset[i].timestamp - lastT)
    lastT = dataset[i].timestamp
  elseif dataset[i].type == 'label' then
    print(dataset[i].timestamp - lastT)
    lastT = dataset[i].timestamp
  end
end
