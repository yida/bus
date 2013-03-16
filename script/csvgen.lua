require 'ucm'

require 'include'
require 'common'
require 'poseUtils'
require 'torch-load'
require 'GPSUtils'

local serialization = require('serialization');

local datasetpath = '../data/150213185940.20/'
--local datasetpath = '../data/010213180247/'
local dataset = loadDataMP(datasetpath, 'gpsLocalMP', _, 1)

saveCsvMP(dataset, 'csv', './')
