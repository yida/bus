require 'include'
require 'common'

local datasetpath = '../data/dataset9/'
local magset = loadData(datasetpath, 'mag')

magPruned = pruneTUC(magset)

saveData(magPruned, 'magPruned')

