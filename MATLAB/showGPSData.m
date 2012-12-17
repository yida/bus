global gpsData;

dataSize = size(gpsData, 2);

LatLnt = cell(0);
LatLntCounter = 0;

for count = 1 : dataSize 
  GPS = gpsData{count};
  GPS.tstamp;
  switch GPS.line(1:6)
    case '$GPGGA'
      fprintf('GPGGA - Global Positioning System Fix Data\n');
      fprintf('%s\n', GPS.line);
      %Scan GPGGA sentense 
       % timestamp %f
       % Latitute of next waypoint %f
       % North / South %c
       % Longitude of next waypoint %f
       % East / West %c
       % GPS quality indicator %d
       % Number of satelltes in use %d
       % Horizontal dilution of position (Relative accuracy of horizontal position) %f
       % Antenna altitude above mean seas level %f
       % Meters (Antenna height unit) %c
       % 
      data = sscanf(GPS.line, '$GPGGA,%f,%f,%c,%f,%c,%d,%d,%f,%f,%c,%f,%c,,,%s');
      fprintf('Lat: %f %c, Lon: %f %c at %f\n',...
                                data(2), data(3), data(4), data(5), data(1));
      LatLntCounter = LatLntCounter + 1;
      LatLnt{LatLntCounter} = {data(1), GPS.tstamp, data(2), char(data(3)), data(4), char(data(5)), 0};
%      pause(0.5);
    case '$GPGLL'
      fprintf('GPGLL - Geographic Position, Latitude / Longitude and time\n');
      fprintf('%s\n', GPS.line);
      % Scan GPGLL sentense
      % Latitude %f
      % North / South %c
      % Longitude %f
      % East / West %c
      % UTC of position %f
      data = sscanf(GPS.line, '$GPGLL,%f,%c,%f,%c,%f,%c,%s');
      fprintf('Lat: %f %c, Lon: %f %c at %f\n',...
                                data(1), data(2), data(3), data(4), data(5));
      LatLntCounter = LatLntCounter + 1;
      LatLnt{LatLntCounter} = {data(5), GPS.tstamp, data(1), char(data(2)), data(3), char(data(4)), 0};%      pause(0.5);
    case '$GPGSA'
%      disp('GPGSA');
    case '$GPGSV'
%      disp('GPGSV');
    case '$GPRMC'
      fprintf('GPRMC - Recommended minimum specific GPS/Transit data\n');    
      fprintf('%s\n', GPS.line);
      % Scan GPRMC sentense
      % UTC of position %f
      % Latitude %f
      % North / South %c
      % Longitude %f
      % East / West %c
      % Speed in knots %f
      % Date stamp %f
      data = sscanf(GPS.line, '$GPRMC,%f,%c,%f,%c,%f,%c,%f,%f,%s');
      fprintf('Lat: %f %c, Lon: %f %c at %f with %f knots\n',...
                                data(3), data(4), data(5), data(6), data(1), data(7));
      LatLntCounter = LatLntCounter + 1;
      LatLnt{LatLntCounter} = {data(1), GPS.tstamp, data(3), char(data(4)), data(5), char(data(6)), 0};%     pause(0.5);
    case '$GPVTG'
      fprintf('GPVTG - Track Made Good and Ground Speed\n');
      fprintf('%s\n', GPS.line);
      % Scan GPVTG sentense
      % Track mode good, %f
      % T %c
      % not used 
      % M (not used) %c
      % Ground speed in knot %f
      % N %c
      % Ground speed in km/hour %f
      % K %c
      data = textscan(GPS.line, '$GPVTG %f %c %f %c %f %c %f %c %s', 'Delimiter', ',');
      fprintf('Ground speed %f %c or %f %c\n',...
                                data{5}, data{6}, data{7}, data{8});
%     pause(0.5);
    otherwise
      disp(GPS.line(1:6));
  end
end

LatLnt = LatLnt(:, 1: LatLntCounter);
