local ucm = require 'ucm'

require 'include'
require 'common'
require 'poseUtils'
require 'torch'
require 'GPSUtils'

local datasetpath = '../data/150213185940.20/'
--local datasetpath = '../data/010213180247/'
--local datasetpath = './'
local dataset = loadDataMP(datasetpath, 'gpsLocalMP', _, 1)

local counter = 0
local labelcounter = 0
local hmin = 10000
local hmax = 0
local vmin = 10000
local vmax = 0

for i = 1, #dataset do
  if dataset[i].type == 'gps' then
    util.ptable(dataset[i])
    error()
--    if dataset[i].satellites ~= nil then
--      print(dataset[i].satellites)
--      counter = counter + 1
--    end
        counter = counter + 1 
        if type(dataset[i].VDOP) == 'string' then
          dataset[i].VDOP = tonumber(dataset[i].VDOP)
        end
        HDOP = dataset[i].HDOP
        VDOP = dataset[i].VDOP
        PDOP = dataset[i].PDOP
        Satellites = dataset[i].satellites
        -- HACK: map satellite nums to DOP likelihood
--        pDOP = 0.175 * Satellites - 0.6
        pDOP = 0.117 * Satellites - 0.37
        if pDOP < 0 then pDOP = 0 end
        if pDOP > 1 then pDOP = 1 end
        rHDOP = ( math.sqrt(HDOP^2/2) * (1 - pDOP) )^2
        rVDOP = ( VDOP * (1 - pDOP) )^2
        rPDOP = ( PDOP * (1 - pDOP) )^2
        if HDOP < hmin then hmin = HDOP end
        if HDOP > hmax then hmax = HDOP end
        if VDOP < vmin then vmin = VDOP end
        if VDOP > vmax then vmax = VDOP end
        
        print(dataset[i].timestamp, dataset[i].latitude, dataset[i].longtitude)
--        print('HDOP '..rHDOP, 'VDOP '..rVDOP, 'PDOP '..rPDOP, 'Satellites '..Satellites, 'DOP Likelihood '..pDOP)
--        print('dxdy '..math.sqrt(HDOP^2/2), 'dz '..math.sqrt(VDOP^2))
--        print(dataset[i].satellites)        
        pos = vector.new({dataset[i].x, dataset[i].y, HDOP})
        ucm.set_ukf_counter(counter)
        ucm.set_ukf_pos(pos)
--      usleep(0.1)
  elseif dataset[i].type == 'label' then
    print(dataset[i].timestamp, dataset[i].value)
  end
end
print(counter)
--print(hmin, hmax, vmin, vmax)
