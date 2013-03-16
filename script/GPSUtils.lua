require 'include'
require 'torch'

require 'GeographicLib'

function nmea2degree(lat, latD, lnt, lntD)
--  print(lat, latD, lnt, lntD)
  -- NMEA Latitude DDDMM.MMM to DDD.DDD
  local nmea2deg = function(value, dir)
--    print(value, dir)
    local degree = math.floor(value/100)
    local minute = value - degree * 100
--    print(degree, minute)
    deg = degree + minute / 60
    if dir == 'S' or dir == 'W' then deg = -deg end
    return deg
  end

  Lat = nmea2deg(lat, latD)
  Lnt = nmea2deg(lnt, lntD)
  return Lat, Lnt
end

function findDateFromGPS(gps)
  local date = ""
  for i = 1, #gps do
    if gps[i].datastamp ~= nil and gps[i].datastamp ~= "" then
      date = gps[i].datastamp..gps[i].utctime
      break;
    end
  end
  return date
end

function global2metric(gps)
  local lat, lnt = nmea2degree(gps.latitude, gps.northsouth, gps.longtitude, gps.eastwest)
  local gpspos = GeographicLib.Forward(lat, lnt, gps.height)
  local pos = torch.DoubleTensor({gpspos.x, gpspos.y, gpspos.z})
  return pos
end

function gpsChecksum(line)
  local trueline = line:sub(2, line:find('*')-1)
  local checksum = line:sub(line:find('*')+1, #line)
  local sum = 0
  for i = 1, #trueline do
    sum = bit.bxor(sum, trueline:byte(i,i))
  end
  sum = bit.tohex(sum)
  sumstr = string.format('%s', sum)
  sumstr = string.upper(sumstr:sub(#sumstr-1, #sumstr))
--  print(sumstr, sumstr == checksum)
  return sumstr == checksum
end

--pos = geo.Forward(27.99, 86.93, 8820)

