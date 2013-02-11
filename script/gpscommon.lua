
function nmea2degree(lat, latD, lnt, lntD)
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
