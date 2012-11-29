function syncData = readBusDataFile(files)

  syncData = 0;
  for cntFiles = 1 : size(files, 2)
    fileIMU = files{cntFiles}{1};
    fileGPS = files{cntFiles}{2};


    % Parse Data
    fprintf('Parsing Data Files at %s...\n', fileIMU(1, 5 : end - 4));
    fidGPS = fopen(fileGPS,'r');
    fidIMU = fopen(fileIMU,'r');
    
    GPSraw = textscan(fidGPS,...
          'Now %f $GPGGA %f %f %c %f %c %u8 %u8 %f %f %c %f %c %f %s',...
          'Delimiter',',');
    IMUraw = textscan(fidIMU,...
          'Now %f R %f P %f Y %f Gx %f Gy %f Gz %f Ax %f Ay %f Az %f %s');
    
    fprintf('Parse Data Files Done! %d GPS Samples, %d IMU Samples\n',...
            size(GPSraw{1},1), size(IMUraw{1},1));
    
    
    % Merge IMU and GPS with time sync
    DimIMU = size(IMUraw,2);
    DimGPS = size(GPSraw,2);
    SampleGPS = size(GPSraw{1},1);
    SampleIMU = size(IMUraw{1},1);
    
    % timeStamp, time, Lat, NS, Lon, EW, Alti, r, p ,y, Gx, Gy, Gz, Ax, Ay, Az, Label
    sync = zeros(17, SampleIMU);
    
    cntGPS = 1;
    for cntIMU = 1 : SampleIMU
      sync(1, cntIMU) = IMUraw{1}(cntIMU);
      sync(2:7, cntIMU) = zeros(6, 1);
      sync(8:16, cntIMU) = [IMUraw{2}(cntIMU), IMUraw{3}(cntIMU),...
                                IMUraw{4}(cntIMU), IMUraw{5}(cntIMU),...
                                IMUraw{6}(cntIMU), IMUraw{7}(cntIMU),...
                                IMUraw{8}(cntIMU), IMUraw{9}(cntIMU),...
                                IMUraw{10}(cntIMU)];
    
      if strcmp(char(IMUraw{DimIMU}(cntIMU)), 'forward')
          sync(17, cntIMU) = 0;
      elseif strcmp(char(IMUraw{DimIMU}(cntIMU)), 'leftTurnStart')
          sync(17, cntIMU) = 1;
      elseif strcmp(char(IMUraw{DimIMU}(cntIMU)), 'leftTurnOver')
          sync(17, cntIMU) = 2;
      elseif strcmp(char(IMUraw{DimIMU}(cntIMU)), 'rightTurnStart')
          sync(17, cntIMU) = 3;
      elseif strcmp(char(IMUraw{DimIMU}(cntIMU)), 'rightTurnOver')
          sync(17, cntIMU) = 4;
      else
          sync(17, cntIMU) = 5;
      end
      if cntGPS > SampleGPS
        continue;
      end
      if (IMUraw{1}(cntIMU) == GPSraw{1}(cntGPS)) 
        % interpolate GPS to IMU data
        sync(2:7, cntIMU) = [GPSraw{2}(cntGPS), GPSraw{3}(cntGPS),...
                                 double(GPSraw{4}(cntGPS)), GPSraw{5}(cntGPS),... 
                                 double(GPSraw{6}(cntGPS)),GPSraw{10}(cntGPS)];
  %      fprintf('sync %d at %f \n', cntGPS, GPSraw{1}(cntGPS));
        cntGPS = cntGPS + 1;
      end
    end
    fprintf('synced %d GPS Samples \n', cntGPS);
    
    if (cntFiles == 1) 
      syncData = sync;
    else
      syncData = [syncData, sync];
    end
    
    fclose(fidGPS);
    fclose(fidIMU);
  end
    
