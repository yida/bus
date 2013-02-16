require 'include'
require 'common'
require 'gpscommon'

require 'torch-load'

local datasetpath = '../data/010213180247/'
local gpsset = loadData(datasetpath, 'gps')

gps = {}
gpscount = 0

--print(findDateFromGPS(gpsset))
local geo = require 'GeographicLib'
local firstlat = true
local basepos = {0.0, 0.0, 0.0}
local relativePosX = {}
local relativePosY = {} 
local relativeCount = 0
for i = 1, #gpsset do
  if gpsset[i].latitude and gpsset[i].latitude ~= '' then
    lat, lnt = nmea2degree(gpsset[i].latitude, gpsset[i].northsouth, 
                            gpsset[i].longtitude, gpsset[i].eastwest)
    pos = geo.Forward(lat, lnt, 6)
    if firstlat then
      basepos = pos
      firstlat = false
    else
      relativeCount = relativeCount + 1
      relativePosX[relativeCount] = pos.x - basepos.x
      relativePosY[relativeCount] = pos.y - basepos.y
      print(relativePosX[relativeCount], relativePosY[relativeCount])
    end
  end
end

x = torch.Tensor(#relativePosX)
y = torch.Tensor(#relativePosY)
for i = 1, #relativePosX do 
  x[i] = relativePosX[i]
  y[i] = relativePosY[i]
end

--gnuplot.figure(2)
gnuplot.plot(x, y, '.')
