require 'include'
require 'common'

local datasetpath = '../data/'
--local datasetpath = '../data/dataset9/'
local magset = loadData(datasetpath, 'magPruned')

--magPruned = pruneTUC(magset)

--saveData(magPruned, 'magPruned')

print(#magPruned)
