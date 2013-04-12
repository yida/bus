require 'include'
require 'common'
require 'poseUtils'
require 'torch'
local util = require 'util'

local datasetpath = '../data/150213185940.20/'
local dataset = loadDataMP(datasetpath, 'yawtestGauMP', _, 1)

for i = 1, #dataset do
  util.ptable(dataset[i].alpha)
end

