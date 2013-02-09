require 'include'
require 'common'

local datasetpath = '../data/dataset9/'
local imuset = loadData(datasetpath, 'imu')


imuPruned = pruneTUC(imuset)

--saveData(imuPruned, 'imuPruned')

