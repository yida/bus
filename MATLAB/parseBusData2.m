function syncData = parseBusData2()
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


%fileSuffix = input('Input MM-DD-HH-MM for the start file:','s');

% get txt file list
dateStamp = '2012121321';
filePath = strcat('data/', dateStamp);
imufileList = dir(strcat(filePath,'/imu*'));
gpsfileList = dir(strcat(filePath,'/gps*'));
magfileList = dir(strcat(filePath,'/mag*'));

fileSuffix = '12311901';

fileGPS = strcat('gps', fileSuffix);
fileIMU = strcat('imu', fileSuffix);
fileMAG = strcat('mag', fileSuffix);


%% check if filename match
fileGPSFound = 0;
fileGPSIdx = 0;
for cnt = 1 : size(gpsfileList, 1)
  matchstart = regexp(gpsfileList(cnt).name, fileGPS);
  if ~isempty(matchstart)
    fileGPSFound = fileGPSFound + 1;
    fileGPSIdx = cnt;
  end
end
fileIMUFound = 0;
fileIMUIdx = 0;
for cnt = 1 : size(imufileList, 1)
  matchstart = regexp(imufileList(cnt).name, fileIMU);
  if ~isempty(matchstart)
    fileIMUFound = fileIMUFound + 1;
    fileIMUIdx = cnt;
  end
end
fileMAGFound = 0;
fileMAGIdx = 0;
for cnt = 1 : size(magfileList, 1)
  matchstart = regexp(magfileList(cnt).name, fileMAG);
  if ~isempty(matchstart)
    fileMAGFound = fileMAGFound + 1;
    fileMAGIdx = cnt;
  end
end
fileIMUFound;
fileGPSFound;
fileMAGFound;

global imuData;
imuData = cell(0);
imuDataCounter = 0;
%parsing imu files
for cnt = 0 : fileIMUFound - 1
%for cnt = 0
  fileimu = strcat(filePath, '/', fileIMU, num2str(cnt));
  fidimu = fopen(fileimu, 'r');
  [A, count] = fread(fidimu, inf, 'uint8=>uint8');
  fclose(fidimu);

  for numlines = 0 : floor(count / 41) - 1
  % imu string length 41 = 16 timeStamp + 24 data + \n
%  for numlines = 2

    tline = A(1 + 41 * numlines : 41 + 41 * numlines);
    timeStamp = char(tline(1:16)');
    imuline = tline(12:end);
    
    imu.tstamp = str2num(timeStamp);
    imu.tuc  = typecast(imuline(6:9),'uint32');
    imu.id   = double(imuline(10));
    imu.cntr = double(imuline(11));
    imu.rpy  = double(typecast(imuline(12:17),'int16')) / 5000; %scaling
    imu.wrpy = double(typecast(imuline(18:23),'int16')) / 500;  %scaling
    imu.acc  = double(typecast(imuline(24:29),'int16')) / 5000;
    imu

    imuDataCounter = imuDataCounter + 1;
    imuData{imuDataCounter} = imu;
  end
end

global gpsData;
gpsData = cell(0);
gpsDatacounter = 0;
%parsing gps files
for cnt = 0 : fileGPSFound - 1
%for cnt = 0
  filegps = strcat(filePath, '/', fileGPS, num2str(cnt));
  fidgps = fopen(filegps, 'r');
  
  gpsline = fgets(fidgps);
  while ischar(gpsline)
    gps.tstamp = str2num(gpsline(1:16));
    gps.line = gpsline(17:end);
    disp(gps.line);
    gpsDatacounter = gpsDatacounter + 1;
    gpsData{gpsDatacounter} = gps;
    gpsline = fgets(fidgps);
  end
  fclose(fidgps);
end

global magData;
magData = cell(0);
magDataCounter = 0;
%parsing mag files
for cnt = 0 : fileMAGFound - 1
%for cnt = 0
  filemag = strcat(filePath, '/', fileMAG, num2str(cnt));
  fidmag = fopen(filemag, 'r');
  [A, count] = fread(fidmag, inf, 'uint8=>uint8');
  fclose(fidmag);

  for numlines = 0 : floor(count / 36) - 1
  % imu string length 36 = 16 timeStamp + 19 data + \n
%  for numlines = 2

    tline = A(1 + 36 * numlines : 36 + 36 * numlines);
    timeStamp = char(tline(1:16)');
    pmagline = tline(12:end);
    
    pmag.tstamp = str2num(timeStamp);
    pmag.id    = double(pmagline(6));
    pmag.tuc   = typecast(pmagline(7:10),'uint32');
    pmag.press = double(typecast(pmagline(11:12),'int16')) + 100000; %pascals
    pmag.temp  = double(typecast(pmagline(15:16),'int16')) / 100; %deg celcius
    pmag.mag   = double(typecast(pmagline(19:24),'int16'));
    magDataCounter = magDataCounter + 1;
    pmag
    magData{magDataCounter} = pmag;
  end

end



%
%% Check file exists
%if (fileIMUFound < 1)
%  fprintf('Imu file %s not found\n',fileIMU);
%  return;
%else
%  fprintf('Imu file %s found at %d\n',fileIMU, fileIMUIdx);
%end
%if (fileGPSFound < 1)
%  fprintf('Gps file %s not found\n',fileGPS);
%  return;
%else
%  fprintf('Gps file %s found at %d\n',fileGPS, fileGPSIdx);
%end
%
%files = {};
%nfiles = 0;
%
%while (1)
%  fileGPSIdx = fileGPSIdx + 1;
%  fileIMUIdx = fileIMUIdx + 1;
%  % check filename length
%  if (size(fileList(fileGPSIdx).name, 2) ~= size(fileList(fileIMUIdx).name, 2))
%    fprintf('End of Data File List.\n');
%    break;
%  end
%  % check filename data stamp
%  if (strcmp(fileList(fileGPSIdx).name(1,4:end), fileList(fileIMUIdx).name(1,4:end)) == 0)
%    fprintf('IMU and GPS data stamp not match!\n');
%    break;
%  end  
%  fprintf('Next Data file %s (%d) and %s (%d)\n', fileList(fileIMUIdx).name,...
%        fileList(fileIMUIdx).bytes, fileList(fileGPSIdx).name, fileList(fileGPSIdx).bytes);
%  cmd = input('Add these files? [Y/N/E]\n','s');
%  switch cmd 
%  case {'Y','y'}
%    disp('accept file');
%    nfiles = nfiles + 1;
%    files{nfiles} = {fileList(fileIMUIdx).name, fileList(fileGPSIdx).name};
%  case {'n','N'}
%    disp('ignore file');
%  case {'e','E'}
%    disp('end file selection');
%    break;
%  otherwise
%    fprintf('wrong key, must be Y/y (Accept), N/n (Ignore), E/e (end)\n');
%    fileGPSIdx = fileGPSIdx - 1;
%    fileIMUIdx = fileIMUIdx - 1;
%  end
%end
%
%%syncData = readBusDataFile(fileIMU, fileGPS);
%syncData = readBusDataFile(filesiiii);
