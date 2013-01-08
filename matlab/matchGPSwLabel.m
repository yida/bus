sizeLabel = size(label, 2);
sizeGPS = size(LatLnt, 2);

gpscount = 1;
labelcount = 1;
labelt = label{1}.tstamp;
gpst = LatLnt{gpscount}{2};

for labelcount = 1 : sizeLabel
  labelt = label{labelcount}.tstamp;
  gpst = LatLnt{gpscount}{2};

  lastTdiff = 1000;
  while (abs(labelt - gpst) < lastTdiff) & (gpscount < sizeGPS)
    lastTdiff = abs(labelt - gpst);
    gpscount = gpscount + 1;
    gpst = LatLnt{gpscount}{2};
  end
  
  fprintf(1, 'min time diff to label %d: %f at GPS frame %d\n',...
        labelcount, labelt-LatLnt{gpscount-1}{2}, gpscount);
end
