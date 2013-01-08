fidGPS = fopen('Gps-11-13-16-19.txt','r');
fidIMU = fopen('Imu-11-13-16-19.txt','r');
GPSraw = textscan(fidGPS,...
      'Now %f $GPGGA %f %f %c %f %c %u8 %u8 %f %f %c %f %c %f %s',...
      'Delimiter',',');
IMUraw = textscan(fidIMU,...
      'Now %f R %f P %f Y %f Gx %f Gy %f Gz %f Ax %f Ay %f Az %f %s');


DimIMU = size(IMUraw,2);
DimGPS = size(GPSraw,2);
SampleGPS = size(GPSraw{1},1);
SampleIMU = size(IMUraw{1},1);

% timeStamp, time, Lat, NS, Lon, EW, Alti, r, p ,y, Gx, Gy, Gz, Ax, Ay, Az
syncData = zeros(17, SampleIMU);

cntGPS = 1;
for cntIMU = 1 : SampleIMU
  syncData(1, cntIMU) = IMUraw{1}(cntIMU);
  syncData(2:7, cntIMU) = zeros(6, 1);
  syncData(8:16, cntIMU) = [IMUraw{2}(cntIMU), IMUraw{3}(cntIMU),...
                            IMUraw{4}(cntIMU), IMUraw{5}(cntIMU),...
                            IMUraw{6}(cntIMU), IMUraw{7}(cntIMU),...
                            IMUraw{8}(cntIMU), IMUraw{9}(cntIMU),...
                            IMUraw{10}(cntIMU)];

  if strcmp(char(IMUraw{DimIMU}(cntIMU)), 'forward')
      syncData(17, cntIMU) = 0;
  elseif strcmp(char(IMUraw{DimIMU}(cntIMU)), 'leftTurnStart')
      syncData(17, cntIMU) = 1;
  elseif strcmp(char(IMUraw{DimIMU}(cntIMU)), 'leftTurnOver')
      syncData(17, cntIMU) = 2;
  elseif strcmp(char(IMUraw{DimIMU}(cntIMU)), 'rightTurnStart')
      syncData(17, cntIMU) = 3;
  elseif strcmp(char(IMUraw{DimIMU}(cntIMU)), 'rightTurnOver')
      syncData(17, cntIMU) = 4;
  else
      syncData(17, cntIMU) = 5;
  end
  if cntGPS > SampleGPS
    continue;
  end
  if (IMUraw{1}(cntIMU) == GPSraw{1}(cntGPS)) 
    % interpolate GPS to IMU data
    syncData(2:7, cntIMU) = [GPSraw{2}(cntGPS), GPSraw{3}(cntGPS),...
                             double(GPSraw{4}(cntGPS)), GPSraw{5}(cntGPS),... 
                             double(GPSraw{6}(cntGPS)),GPSraw{10}(cntGPS)];
    fprintf('sync %d at %f \n', cntGPS, GPSraw{1}(cntGPS));
    cntGPS = cntGPS + 1;
  end
end


fclose(fidGPS);
fclose(fidIMU);
