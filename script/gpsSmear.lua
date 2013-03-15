require 'ucm'

require 'include'
require 'common'
require 'poseUtils'
require 'torch-load'
require 'GPSUtils'

local mp = require 'MessagePack'

local serialization = require('serialization');

local datasetpath = '../data/150213185940/'
--local datasetpath = '../data/010213180247/'
--local datasetpath = '../data/010213192135/'
--local datasetpath = '../data/191212190259/'
--local datasetpath = '../data/211212164337/'
--local datasetpath = '../data/211212165622/'
local datasetpath = './'
--local dataset = loadDataMP(datasetpath, 'gpsMP', _, 1)
local obs = loadData(datasetpath, 'obs', _, 1)
print('done loading data')

earth = Geocentric.new(Constants.WGS84_a(), Constants.WGS84_f())

latinit = 39.951862166667 
loninit = -75.190061166667
heightinit = 8.9
proj = LocalCartesian.new(latinit, loninit, heightinit, earth)

for i = 1, #obs do
  ret = proj:Reverse(obs[i].x, obs[i].y, obs[i].z)
  print(ret.lat, ret.lon, ret.h)
  obs[i].lat = ret.lat
  obs[i].lon = ret.lon
  obs[i].h = ret.h
end

--saveData(obs, 'obsall', './')
saveCsvMP(obs, 'obscsv', './')
