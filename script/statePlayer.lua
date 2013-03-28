local ucm = require 'ucm'

require 'include'
require 'common'
require 'poseUtils'
require 'torch'
require 'unix'

local datasetpath = '../data/150213185940.20/'
local datasetpath = './'
--local dataset = loadData(datasetpath, 'observation', _, 1)
t0 = unix.time()
--local dataset = loadDataMP(datasetpath, 'statewlabelMP', _, 1)
--local dataset = loadDataMP(datasetpath, 'obsMP', _, 1)
local dataset = loadDataMP(datasetpath, 'stateMP-03.27.2013.17.00.57-0', _, 1)
print(#dataset)

local counter = 0
local labelcounter = 0
for i = 1, #dataset do
--  if dataset[i].timestamp >= 946687159.94 and dataset[i].timestamp <= 946687184.94 then 
    if dataset[i].type == 'state' then
      local tstep = dataset[i].timestamp
      local vec = torch.DoubleTensor({dataset[i].e1, dataset[i].e2, dataset[i].e3})
      local Q = Vector2Quat(vec)
      
      counter = counter + 1 
      
      print(dataset[i].timestamp, dataset[i].x, dataset[i].y, dataset[i].z, dataset[i].label)
--      print(counter)
      
      q = vector.new({Q[1], Q[2], Q[3], Q[4]})
      pos = vector.new({dataset[i].x, dataset[i].y, dataset[i].z})
      ucm.set_ukf_counter(counter)
      ucm.set_ukf_quat(q)
      ucm.set_ukf_pos(pos)
--      usleep(0.04)
--    elseif dataset[i].type == 'label' then
--      print(dataset[i].timestamp, dataset[i].value)
      labelcounter = labelcounter + 1
      ucm.set_label_counter(labelcounter)
      ucm.set_label_value(dataset[i].label)
      usleep(0.02)
    end
--  end
end
