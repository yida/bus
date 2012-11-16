function parseBusData()
% This is a function to parse the data taken by logBusData
%
%   Author: Yida Zhang (yida@seas.upenn.edu)
%
% Always run this script in the folder containing data files
% or sue addpath('PATH to the folder')
%


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

fprintf('Parsing Data Files...\n');
fidGPS = fopen(fileGPS,'r');
fidIMU = fopen(fileIMU,'r');

GPSraw = textscan(fidGPS,...
      'Now %f %s %f %f %c %f %c %u8 %u8 %f %f %c %f %c %f %s',...
      'Delimiter',',');
IMUraw = textscan(fidIMU,...
      'Now %f R %f P %f Y %f Gx %f Gy %f Gz %f Ax %f Ay %f Az %f %s');

fprintf('Parse Data Files Done! %d GPS Samples, %d IMU Samples\n',...
        size(GPSraw{1},1), size(IMUraw{1},1));


fclose(fidGPS);
fclose(fidIMU);

