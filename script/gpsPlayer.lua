require 'ucm'

require 'include'
require 'common'
require 'poseUtils'
require 'torch-load'
require 'GPSUtils'

local serialization = require('serialization');

local datasetpath = '../data/150213185940/'
--local datasetpath = '../data/010213180247/'
local dataset = loadData(datasetpath, 'gpsLocal', _, 1)

local counter = 0
local labelcounter = 0
for i = 1, #dataset do
  if dataset[i].type == 'gps' then
        counter = counter + 1 
        
        pos = vector.new({dataset[i].x, dataset[i].y, dataset[i].z})
        ucm.set_ukf_counter(counter)
        ucm.set_ukf_pos(pos)
      usleep(0.1)
  end
end
