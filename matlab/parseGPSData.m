global gpsData;

dataSize = size(gpsData, 2);

LatLnt = cell(0);
LatLntCounter = 0;

debug = false;
for count = 1 : dataSize 
  GPS = gpsData{count};
  GPS.tstamp;
%  GPS.label
  switch GPS.line(1:6)
    case '$GPGGA'
      if debug 
        fprintf('GPGGA - Global Positioning System Fix Data\n');
        fprintf('%s\n', GPS.line);
      end
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
%     data = sscanf(GPS.line, '$GPGGA,%f,%f,%c,%f,%c,%d,%d,%f,%f,%c,%f,%c,,,%s');
      data = textscan(GPS.line, '$GPGGA %f %f %c %f %c %d %d %f %f %c %f %c %f %f %s', 'Delimiter', ',');
      if size(data, 2) > 2
        if debug
          fprintf('Lat: %f %c, Lon: %f %c at %f\n',...
                                    data{2}, data{3}, data{4}, data{5}, data{1});
        end
        LatLntCounter = LatLntCounter + 1;
        gps = GPS;
        gps.utctime = data{1};
        gps.latitude = data{2};
        gps.northsouth = char(data{3});
        gps.longtitude = data{4};
        gps.eastwest = char(data{5});
        gps.satellites = data{7};
        gps.HDOP = data{8};
        gps.height = data{9};
        gps.wgs84height = data{11};
        LatLnt{LatLntCounter} = gps;
  %      pause(0.5);
      end
    case '$GPGLL'
      if debug
       fprintf('GPGLL - Geographic Position, Latitude / Longitude and time\n');
       fprintf('%s\n', GPS.line);
      end
      % Scan GPGLL sentense
      % Latitude %f
      % North / South %c
      % Longitude %f
      % East / West %c
      % UTC of position %f
%      data = sscanf(GPS.line, '$GPGLL,%f,%c,%f,%c,%f,%c,%s');
      data = textscan(GPS.line, '$GPGLL %f %c %f %c %f %c %s', 'Delimiter', ',');
      if size(data, 2) > 2
        if debug
          fprintf('Lat: %f %c, Lon: %f %c at %f\n',...
                                  data{1}, data{2}, data{3}, data{4}, data{5});
        end
        LatLntCounter = LatLntCounter + 1;
        gps = GPS;
        gps.utctime = data{5};
        gps.latitude = data{1};
        gps.northsouth = char(data{2});
        gps.longtitude = data{3};
        gps.eastwest = char(data{4});
        LatLnt{LatLntCounter} = gps;
        %pause(0.5);
      end
    case '$GPGSA'
      if debug
       fprintf('%s\n', GPS.line);
      end
%      disp('GPGSA');
%     data = sscanf(GPS.line, '$GPGSA,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f');
      data = textscan(GPS.line, '$GPGSA %c %d %d %d %d %d %d %d %d %d %d %d %d %d %f %f %f', 'Delimiter', ',');
      if size(data, 2) > 2
        LatLntCounter = LatLntCounter + 1;
        gps = GPS;
        gps.PDOP = data{15};
        gps.HDOP = data{16};
        gps.VDOP = data{17};
        LatLnt{LatLntCounter} = gps;
      end
      %pause(0.5);
    case '$GPGSV'
%      disp('GPGSV');
    case '$GPRMC'
      if debug
        fprintf('GPRMC - Recommended minimum specific GPS/Transit data\n');    
        fprintf('%s\n', GPS.line);
      end
      % Scan GPRMC sentense
      % UTC of position %f
      % Latitude %f
      % North / South %c
      % Longitude %f
      % East / West %c
      % Speed in knots %f
      % Date stamp %f
%      data = sscanf(GPS.line, '$GPRMC,%f,%c,%f,%c,%f,%c,%f,%f,%f,%f,%c,%f');
      data = textscan(GPS.line, '$GPRMC %f %c %f %c %f %c %f %f %f %f %c %s', 'Delimiter', ',');
      if size(data, 2) > 2
        if debug
          fprintf('Lat: %f %c, Lon: %f %c at %f with %f knots\n',...
                                  data{3}, data{4}, data{5}, data{6}, data{1}, data{7});
        end
        LatLntCounter = LatLntCounter + 1;
%        LatLnt{LatLntCounter} = {data{1), GPS.tstamp, data{3), char(data{4)), data{5), char(data{6)), 0};%     pause(0.5);
        gps = GPS;
        gps.utctime = data{1};
        gps.latitude = data{3};
        gps.northsouth = char(data{4});
        gps.longtitude = data{5};
        gps.eastwest = char(data{6});
        gps.nspeed = data{7};
        gps.truecourse = data{8};
        gps.datastamp = data{9};
        gps.magneticvar = data{10};
        gps.magneticvard = char(data{11});
                                       %     pause(0.5);
        LatLnt{LatLntCounter} = gps;
      end
    case '$GPVTG'
      if debug
        fprintf('GPVTG - Track Made Good and Ground Speed\n');
        fprintf('%s\n', GPS.line);
      end
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
      if size(data, 2) > 2
        if debug
        fprintf('Ground speed %f %c or %f %c\n',...
                                  data{5}, data{6}, data{7}, data{8});
        end
        LatLntCounter = LatLntCounter + 1;
        gps = GPS;
        gps.truecourse = data{1};
        gps.magneticcourse = data{3};
        gps.nspeed = data{5};
        gps.kspeed = data{7};
        LatLnt{LatLntCounter} = gps;
  %     pause(0.5);
      end
    otherwise
      disp(GPS.line(1:6));
  end
end

LatLnt = LatLnt(:, 1: LatLntCounter);
