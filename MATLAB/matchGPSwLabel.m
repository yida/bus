sizeLabel = size(label, 2);
sizeGPS = size(LatLnt, 2);

labelt = label{1}.tstamp;
gpst = LatLnt{1}[2];

gpscount = 1;
labelt = label{1}.tstamp;
gpst = LatLnt{gpscount}[2];

while (labelt > gpst)

end

