require 'include'
require 'common'

local datasetpath = './'
local gpsset = loadData(datasetpath, 'gps')

gps = {}
gpscount = 0

function findDateFromGPS(gps)
  local date = ""
  for i = 1, #gps do
    if gps[i].datastamp ~= nil and gps[i].datastamp ~= "" then
      date = gps[i].datastamp..gps[i].utctime
  --    print('\r'..gps[i].datastamp, gps[i].utctime)
      break;
    end
  end
  return date
end

print(findDateFromGPS(gpsset))
