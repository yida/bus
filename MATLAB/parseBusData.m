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
fileGPSIdx = 0;
fileIMUFound = 0;
fileIMUIdx = 0;
for cnt = 1 : size(fileList, 1)
  matchstart = regexp(fileList(cnt).name, fileGPS);
  if ~isempty(matchstart)
    fileGPSFound = fileGPSFound + 1;
    fileGPSIdx = cnt;
  end
  matchstart = regexp(fileList(cnt).name, fileIMU);
  if ~isempty(matchstart)
    fileIMUFound = fileIMUFound + 1;
    fileIMUIdx = cnt;
  end
end

% Check file exists
if (fileIMUFound < 1)
  fprintf('Imu file %s not found\n',fileIMU);
  return;
else
  fprintf('Imu file %s found at %d\n',fileIMU, fileIMUIdx);
end
if (fileGPSFound < 1)
  fprintf('Gps file %s not found\n',fileGPS);
  return;
else
  fprintf('Gps file %s found at %d\n',fileGPS, fileGPSIdx);
end

files = {};
nfiles = 0;

while (1)
  fileGPSIdx = fileGPSIdx + 1;
  fileIMUIdx = fileIMUIdx + 1;
  % check filename length
  if (size(fileList(fileGPSIdx).name, 2) ~= size(fileList(fileIMUIdx).name, 2))
    fprintf('End of Data File List.\n');
    break;
  end
  % check filename data stamp
  if (strcmp(fileList(fileGPSIdx).name(1,4:end), fileList(fileIMUIdx).name(1,4:end)) == 0)
    fprintf('IMU and GPS data stamp not match!\n');
    break;
  end  
  fprintf('Next Data file %s (%d) and %s (%d)\n', fileList(fileIMUIdx).name,...
        fileList(fileIMUIdx).bytes, fileList(fileGPSIdx).name, fileList(fileGPSIdx).bytes);
  cmd = input('Add these files? [Y/N/E]\n','s');
  switch cmd 
  case {'Y','y'}
    disp('accept file');
    nfiles = nfiles + 1;
    files{nfiles} = {fileList(fileIMUIdx).name, fileList(fileGPSIdx).name};
  case {'n','N'}
    disp('ignore file');
  case {'e','E'}
    disp('end file selection');
    break;
  otherwise
    fprintf('wrong key, must be Y/y (Accept), N/n (Ignore), E/e (end)\n');
    fileGPSIdx = fileGPSIdx - 1;
    fileIMUIdx = fileIMUIdx - 1;
  end
end

%syncData = readBusDataFile(fileIMU, fileGPS);
syncData = readBusDataFile(files);
