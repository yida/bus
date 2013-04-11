require 'include'
require 'common'
require 'poseUtils'
require 'torch'
local util = require 'util'

local datasetpath = '../data/150213185940.20/'
--local datasetpath = './'
--local dataset = loadDataMP(datasetpath, 'imuBinaryMP', _, 1)
local dataset = loadDataMP(datasetpath, 'imuPrunedMP', _, 1)
--local dataset = loadDataMP(datasetpath, 'labelMP', _, 1)

lastT = dataset[1].timestamp
for i = 1, #dataset do
  if dataset[i].type == 'imu' then
--    print(dataset[i].timestamp - lastT)
    lastT = dataset[i].timestamp
--    print(dataset[i].ax, dataset[i].ay, dataset[i].az)
    if dataset[i].wy > 0.01 then 
      dataset[i].bwy = 1
    elseif dataset[i].wy < -0.01 then 
      dataset[i].bwy = -1
    else
      dataset[i].bwy = 0
    end
--    math.sqrt(dataset[i].ax^2 + dataset[i].ay^2 + dataset[i].az^2))
  elseif dataset[i].type == 'label' then
    print(dataset[i].timestamp - lastT)
    lastT = dataset[i].timestamp
  end
end

saveDataMP(dataset, 'imuBinaryMP', datasetpath)
