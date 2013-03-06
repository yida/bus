require 'include'
require 'common'

require 'torch-load'

local datasetpath = '../data/211212165622/'


local set = loadData(datasetpath, 'imu')
Pruned = pruneTUC(set)
saveData(Pruned, 'imuPruned')
local set = loadData(datasetpath, 'mag')
Pruned = pruneTUC(set)
saveData(Pruned, 'magPruned')

