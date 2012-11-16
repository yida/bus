function syncData = parseBusData()
% This is a function to parse the data taken by logBusData
%
%   Author: Yida Zhang (yida@seas.upenn.edu)
%
% Always run this script in the folder containing data files
% or sue addpath('PATH to the folder')
%
%   syncData = parseBusData()
%
% syncData : 17 x IMUsample
%      
%   timeStamp, time, Lat, NS, Lon, EW, Alti, 
%              r, p ,y, Gx, Gy, Gz, Ax, Ay, Az, Label


fileSuffix = input('Input MM-DD-HH-MM for the start file:','s');

fileGPS = strcat('Gps-', fileSuffix, '.txt');
fileIMU = strcat('Imu-', fileSuffix, '.txt');

% get txt file list
fileList = dir('*.txt');

% check if filename match
fileGPSFound = 0;
fileIMUFound = 0;
for cnt = 1 : size(fileList, 1)
  matchstart = regexp(fileList(cnt).name, fileGPS);
  if ~isempty(matchstart)
    fileGPSFound = fileGPSFound + 1;
  end
  matchstart = regexp(fileList(cnt).name, fileIMU);
  if ~isempty(matchstart)
    fileIMUFound = fileIMUFound + 1;
  end
end

% Check file exists
if (fileIMUFound < 1)
  fprintf('Imu file %s not found\n',fileIMU);
  return;
else
  fprintf('Imu file %s found\n',fileIMU);
end
if (fileGPSFound < 1)
  fprintf('Gps file %s not found\n',fileGPS);
  return;
else
  fprintf('Gps file %s found\n',fileGPS);
end

% Parse Data
fprintf('Parsing Data Files...\n');
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

