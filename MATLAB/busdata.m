function ReceiveImu()
clear all;
close all;


addpath('ReceiveImu');

current = clock();
% year month day hour minute second

fileImu = strcat('Imu-', num2str(current(2)),'-',... 
                  num2str(current(3)),'-',...
                  num2str(current(4)),'-',...
                  num2str(current(5)),'.txt');
fileGps = strcat('Gps-', num2str(current(2)),'-',...
                  num2str(current(3)),'-',...
                  num2str(current(4)),'-',...
                  num2str(current(5)),'.txt');
fidImu = fopen(fileImu,'w');
fidGps = fopen(fileGps,'w');


global rawVals rawCntr

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
        imuVals = double(typecast(packet(10:end-1),'single'))
%        R = rotz(imuVals(3))*roty(imuVals(2))*rotx(imuVals(1));
        fprintf(fidImu,'Now %f R %f P %f Y %f Gx %f Gy %f Gz %f Ax %f Ay %f Az %f\n',...
                tStep, imuVals(1), imuVals(2), imuVals(3),...
                imuVals(4), imuVals(5), imuVals(6),...
                imuVals(7), imuVals(8), imuVals(9));
        fileCntImu = fileCntImu + 1;
      end
    end
  end
  if ~isempty(gpsPacket) 
    if (strcmp(gpsPacket(1:6),'$GPGGA')==1)
      gpsPacket
      fprintf(fidGps,'Now %f %s',tStep,gpsPacket);
      fileCntGps = fileCntGps + 1;
    end
  end

  if (fileCntImu > fileCntMax)
    current = clock();
% year month day hour minute second
    fclose(fidGps);
    fclose(fidImu);

    fileImu = strcat('Imu-', num2str(current(2)),'-',... 
                  num2str(current(3)),'-',...
                  num2str(current(4)),'-',...
                  num2str(current(5)),'.txt');    
    fileGps = strcat('Gps-', num2str(current(2)),'-',...
                  num2str(current(3)),'-',...
                  num2str(current(4)),'-',...
                  num2str(current(5)),'.txt');
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
