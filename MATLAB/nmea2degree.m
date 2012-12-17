function [Lat, Lnt] = nmea2degree(lat, latD, lnt, lntD)

  % NMEA Latitude DDDMM.MMM to DDD.DDD
  degree = fix(lat/100);
  minute = lat - degree * 100;
  Lat = degree + minute / 60;
  if latD == 'S' 
    Lat = -Lat;
  end
  
  % NMEA Longitude DDDMM.MMM to DDD.DDD
  degree = fix(lnt/100);
  minute = lnt - degree * 100;
  Lnt = degree + minute / 60;
  if lntD == 'W'
    Lnt = -Lnt;
  end


