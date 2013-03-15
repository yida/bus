require 'ucm'

require 'include'
require 'common'
require 'poseUtils'
require 'torch-load'
require 'GPSUtils'

local serialization = require('serialization');

local datasetpath = '../data/150213185940/'
--local datasetpath = '../data/010213180247/'
local dataset = loadData(datasetpath, 'gpsLocal', _, 1)

-- get header , manually sorted
titles = {'x', 'y', 'z', 'latitude', 'longtitude', 'timestamp', 'HDOP', 'PDOP', 'VDOP'}
--for i = 1, #titles do
--  print(titles[i])
--end

local Path = path or './'
local dtype = 'csv'
local filecnt = 0
local filetime = os.date('%m.%d.%Y.%H.%M.%S')
local filename = string.format(dtype.."-%s-%d.csv", filetime, filecnt)
local file = io.open(Path..filename, "w")
 
local headstr = ''
for i = 1, #titles do
  headstr = headstr..titles[i]..','
end
headstr = headstr:sub(1, #headstr-1)
print(headstr)
file:write(headstr..'\n')

for i = 1, #dataset do
--for i = 1, 2 do
  local line = ''
  for j = 1, #titles do
    line = line..dataset[i][titles[j]]..','
  end
  line = line:sub(1, #line-1)
  print(line)
  file:write(line..'\n')
end

file:close()
