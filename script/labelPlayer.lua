require 'ucm'

require 'include'
require 'common'
require 'poseUtils'
require 'torch-load'
require 'GPSUtils'

local serialization = require('serialization');

local datasetpath = '../data/150213185940/'
--local datasetpath = '../data/010213180247/'
local datasetpath = './'
local dataset = loadDataMP(datasetpath, 'labelMP', _, 1)

for i = 1, #dataset do
  if dataset[i].type == 'label' then
    util.ptable(dataset[i])
  end
end
