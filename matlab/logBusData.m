function logBusData()
% This is a function to read IMU and GPS data and save into
% files 'Imu-MM-DD-HH-MM.txt' and 'Gps-MM-DD-HH-MM.txt'.
%
% Author: Yida Zhang (yida@seas.upenn.edu)
%
% Manually label the bus turning :
%   Press key to manually label\n')
%     d - leftTurnStart\n')
%     f - leftTurnOver\n')
%     e - rightTurnStart\n')
%     r - rightTurnOver\n')
%

clear all;
close all;


addpath('ReceiveImu');

current = clock();
% year month day hour minute second

fileImu = sprintf('Imu-%02u-%02u-%02u-%02u.txt', current(2), current(3), current(4), current(5));
fileGps = sprintf('Gps-%02u-%02u-%02u-%02u.txt', current(2), current(3), current(4), current(5));
fidImu = fopen(fileImu,'w');
fidGps = fopen(fileGps,'w');




if ismac() == 1 
  dev = '/dev/tty.usbserial-A1017G1T';
  gpsDev = '/dev/tty.usbmodem1d1141';
else
  dev  = '/dev/ttyUSB0';
  gpsDev  = '/dev/ttyACM0';
end
baud = 1000000;
baudGPS = 38400;
SerialDeviceAPI('connect',dev,baud);
fidGPS = serialopen(gpsDev, baudGPS);

fileCntImu = 0;
fileCntGps = 0;
fileCntMax = 10000;

fprintf(1,'Press key to manually label\n')
fprintf(1,'d - leftTurnStart\n')
fprintf(1,'f - leftTurnOver\n')
fprintf(1,'e - rightTurnStart\n')
fprintf(1,'r - rightTurnOver\n')

while(1)
  %fprintf('.');
  packet = ReceivePacket();
  gpsPacket = fgets(fidGPS);
  tStep = now;
  if ~isempty(packet)
    id   = packet(3);
    type = packet(5);
    
    %fprintf('got packet %d %d\n',id,type);
    
    if (id == 0) %LL
      if (type == 0)
      
      elseif (type == 1)
        c = getch();
        status = 'forward';
        switch c
          case 'd'
            status = 'leftTurnStart'
          case 'f'
            status = 'leftTurnOver'
          case 'e'
            status = 'rightTurnStart'
          case 'r'
            status = 'rightTurnOver'  
        end
        imuVals = double(typecast(packet(10:end-1),'single'));
%        R = rotz(imuVals(3))*roty(imuVals(2))*rotx(imuVals(1));
        fprintf(fidImu,'Now %f R %f P %f Y %f Gx %f Gy %f Gz %f Ax %f Ay %f Az %f %s\n',...
                tStep, imuVals(1), imuVals(2), imuVals(3),...
                imuVals(4), imuVals(5), imuVals(6),...
                imuVals(7), imuVals(8), imuVals(9), status);
        fileCntImu = fileCntImu + 1;
      end
    end
  end
  if ~isempty(gpsPacket) 
    if (strcmp(gpsPacket(1:6),'$GPGGA')==1)
%      gpsPacket
      fprintf(fidGps,'Now %f %s',tStep,gpsPacket);
      fileCntGps = fileCntGps + 1;
    end
  end

  if (fileCntImu > fileCntMax)
    current = clock();
% year month day hour minute second
    fclose(fidGps);
    fclose(fidImu);

    fileImu = sprintf('Imu-%02u-%02u-%02u-%02u.txt', current(2), current(3), current(4), current(5));
    fileGps = sprintf('Gps-%02u-%02u-%02u-%02u.txt', current(2), current(3), current(4), current(5));

    fidImu = fopen(fileImu,'w');
    fidGps = fopen(fileGps,'w');
    fileCntImu = 0;
    fileCntGps = 0;
  end


end

fclose(fidGps);
fclose(fidImu);

    
function ret = ReceivePacket()
persistent packetId buf2

if isempty(packetId)
  packetId = kBotPacketAPI('create');
end

ret = [];

if ~isempty(buf2)
  [packet buf2] = kBotPacketAPI('processBuffer',packetId,buf2);
  if ~isempty(packet)
    ret = packet;
    return;
  end
end

buf = SerialDeviceAPI('read',1000,1000);
[packet buf2] = kBotPacketAPI('processBuffer',packetId,buf);
if ~isempty(packet)
  ret = packet;
end
