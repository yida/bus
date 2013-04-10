require 'include'
require 'common'
require 'poseUtils'
require 'torch'
local util = require 'util'

local datasetpath = '../data/150213185940.20/'
--local datasetpath = '../data/010213180247/'
local datasetpath = './'
local dataset = loadDataMP(datasetpath, 'imuMP', _, 1)
--local dataset = loadDataMP(datasetpath, 'labelMP', _, 1)

lastT = dataset[1].timestamp
for i = 1, #dataset do
  if dataset[i].type == 'imu' then
    print(dataset[i].timestamp - lastT)
    lastT = dataset[i].timestamp
--    print(dataset[i].ax, dataset[i].ay, dataset[i].az, 
--    math.sqrt(dataset[i].ax^2 + dataset[i].ay^2 + dataset[i].az^2))
  elseif dataset[i].type == 'label' then
    print(dataset[i].timestamp - lastT)
    lastT = dataset[i].timestamp
  end
end
