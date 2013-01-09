%function syncData = parseBusData2()
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
dateStamp = '20121221route42';
filePath = strcat('data/', dateStamp);
imufileList = dir(strcat(filePath,'/imu*'));
gpsfileList = dir(strcat(filePath,'/gps*'));
magfileList = dir(strcat(filePath,'/mag*'));

fileSuffix = '12311916';

fileGPS = strcat('gps', fileSuffix);
fileIMU = strcat('imu', fileSuffix);
fileMAG = strcat('mag', fileSuffix);

imuflag = true;
gpsflag = false;
magflag = false;

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
fileIMUFound
fileGPSFound
fileMAGFound


if imuflag
  imuData = cell(0);
  imuDataCounter = 0;
  %parsing imu files
  for cnt = 0 : fileIMUFound - 1
  %for cnt = 0
    fileimu = strcat(filePath, '/', fileIMU, num2str(cnt));
    fidimu = fopen(fileimu, 'r');
    [A, count] = fread(fidimu, inf, 'uint8=>uint8');
    fclose(fidimu);
  
    for numlines = 0 : floor(count / 43) - 1
    % imu string length 43 = 16 timeStamp + 2 label + 24 data + \n
  %  for numlines = 2
  
      tline = A(1 + 43 * numlines : 43 + 43 * numlines);
      timeStamp = char(tline(1:16)');
      imu.label = char(tline(17:18)');
        [imu.label(1), imu.label(2)];
        if imu.label(1) == 1
          disp(imu.label(1));
        end
        if imu.label(2) == 1
          disp(imu.label(2));
        end
      imuline = tline(14:end);
      
      imu.tstamp = str2num(timeStamp);
      imu.tuc  = typecast(imuline(6:9),'uint32');
      imu.id   = double(imuline(10));
      imu.cntr = double(imuline(11));
      imu.rpy  = double(typecast(imuline(12:17),'int16')) / 5000; %scaling
      imu.wrpy = double(typecast(imuline(18:23),'int16')) / 500;  %scaling
      imu.acc  = double(typecast(imuline(24:29),'int16')) / 5000;
  
      imuDataCounter = imuDataCounter + 1;
      imuData{imuDataCounter} = imu;
      fprintf('%d\n', imuDataCounter);
    end
  end
end

if gpsflag
  gpsData = cell(0);
  gpsDatacounter = 0;
  %parsing gps files
  for cnt = 0 : fileGPSFound - 1
  %for cnt = 0
    filegps = strcat(filePath, '/', fileGPS, num2str(cnt));
    fidgps = fopen(filegps, 'r');
    
    gpsline = fgets(fidgps);
    flag = true;
    while ischar(gpsline) & flag
      gps.tstamp = str2num(gpsline(1:16));
      gps.label = char(gpsline(17:18));
      gps.line = gpsline(19:end);
      disp(gps.line);
      gpsDatacounter = gpsDatacounter + 1;
      gpsData{gpsDatacounter} = gps;
      gpsline = fgets(fidgps);
%      while isempty(findstr(gpsline, 'GP'))
%        flag = false;
%      end
    end
    fclose(fidgps);
  end
  
end

if magflag
  magData = cell(0);
  magDataCounter = 0;
  %parsing mag files
  for cnt = 0 : fileMAGFound - 1
  %for cnt = 0
    filemag = strcat(filePath, '/', fileMAG, num2str(cnt));
    fidmag = fopen(filemag, 'r');
    [A, count] = fread(fidmag, inf, 'uint8=>uint8');
    fclose(fidmag);
  
    for numlines = 0 : floor(count / 38) - 1
    % imu string length 38 = 16 timeStamp + 2 label + 19 data + \n
  %  for numlines = 2
  
      tline = A(1 + 38 * numlines : 38 + 38 * numlines);
      timeStamp = char(tline(1:16)');
      pmag.label = char(tline(17:18)');
      pmagline = tline(14:end);
      
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

end
