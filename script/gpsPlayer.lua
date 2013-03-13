require 'ucm'

require 'include'
require 'common'
require 'poseUtils'
require 'torch-load'
require 'GPSUtils'

local serialization = require('serialization');


local datasetpath = '../data/150213185940/'
local dataset = loadData(datasetpath, 'gps', _, 1)

local counter = 0
local labelcounter = 0
for i = 1, #dataset do
  if dataset[i].type == 'gps' then
    if dataset[i].latitude ~= nil and dataset[i].longtitude ~= nil and dataset[i].height ~= nil and
       dataset[i].latitude ~= '' and dataset[i].longtitude ~= '' and dataset[i].height ~= '' then
--       util.ptable(dataset[i])
      local lat, lnt = nmea2degree(dataset[i].latitude, dataset[i].northsouth, 
                                  dataset[i].longtitude, dataset[i].eastwest)
--      print(lat, lnt)
      local gpspos = global2metric(dataset[i])

      local tstep = dataset[i].timestamp
      
      counter = counter + 1 
      
      pos = vector.new({lnt, lat, 0})
--      pos = vector.new({gpspos[1], gpspos[2], gpspos[3]})
      ucm.set_ukf_counter(counter)
      ucm.set_ukf_pos(pos)
    end
  end

  usleep(0.04)
  
end
