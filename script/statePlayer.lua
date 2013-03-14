require 'ucm'

require 'include'
require 'common'
require 'poseUtils'
require 'torch-load'

local serialization = require('serialization');


local datasetpath = '../data/010213180247/'
local datasetpath = './'
--local dataset = loadData(datasetpath, 'observation', _, 1)
local dataset = loadData(datasetpath, 'obs', _, 1)
--local dataset = loadData(datasetpath, 'state3', _, 1)

local counter = 0
local labelcounter = 0
for i = 1, #dataset do
  if dataset[i].type == 'state' then
    local tstep = dataset[i].timestamp
    local vec = torch.Tensor({dataset[i].e1, dataset[i].e2, dataset[i].e3})
    local Q = Vector2Quat(vec)
    
    counter = counter + 1 
    print(counter)
    
    q = vector.new({Q[1], Q[2], Q[3], Q[4]})
    pos = vector.new({dataset[i].x, dataset[i].y, dataset[i].z})
    ucm.set_ukf_counter(counter)
    ucm.set_ukf_quat(q)
    ucm.set_ukf_pos(pos)
--  elseif dataset[i].type == 'label' then
    labelcounter = labelcounter + 1
    ucm.set_label_counter(labelcounter)
    ucm.set_label_value(dataset[i].label)
  end
  usleep(0.004)
  
end