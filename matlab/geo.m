addpath('/usr/local/libexec/GeographicLib/matlab');

GPS = LatLnt;

GPSsize = size(GPS, 2);
for i = 1 : GPSsize
  GPS{i}.tstamp
end
