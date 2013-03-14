require 'ucm'

require 'include'
require 'common'
require 'poseUtils'
require 'torch-load'
require 'GPSUtils'

local serialization = require('serialization');

local datasetpath = '../data/150213185940/'
local datasetpath = '../data/010213180247/'
local dataset = loadData(datasetpath, 'gps', _, 1)

earth = Geocentric.new(Constants.WGS84_a(), Constants.WGS84_f())
coorInit = false

local counter = 0
local labelcounter = 0
for i = 1, #dataset do
  if dataset[i].type == 'gps' then
    if dataset[i].latitude ~= nil and dataset[i].longtitude ~= nil and dataset[i].height ~= nil and
       dataset[i].latitude ~= '' and dataset[i].longtitude ~= '' and dataset[i].height ~= '' then
      local lat, lnt = nmea2degree(dataset[i].latitude, dataset[i].northsouth, 
                                  dataset[i].longtitude, dataset[i].eastwest)
--      local gpspos = global2metric(dataset[i])
      if not coorInit then  
        proj = LocalCartesian.new(lat, lnt, dataset[i].height, earth)
        coorInit = true
      else
        ret = proj:Forward(lat, lnt, dataset[i].height)
        print(ret.x, ret.y, ret.z)
        local tstep = dataset[i].timestamp
        
        counter = counter + 1 
        
        pos = vector.new({ret.x, ret.y, ret.z})
  --      pos = vector.new({gpspos[1], gpspos[2], gpspos[3]})
        ucm.set_ukf_counter(counter)
        ucm.set_ukf_pos(pos)
      end
      usleep(0.01)
    end
  end

  
end
