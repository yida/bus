function ReceivePackets()
clear all;
close all;

addpath ../../api
dev  = '/dev/ttyUSB0';
baud = 230400;
SerialDeviceMexAPI('connect',dev,baud);

while(1)
% fprintf('.');
  packet = ReceivePacket();
  if ~isempty(packet)
    id   = packet(3);
    type = packet(5);
    len  = length(packet);
    
    %fprintf('got packet %d %d\n',id,type);
    
    if (id ~= 0), continue, end
    
    switch (type)
      case 31 %gps
        gpsStr = char(packet(6:end-8));
%       fprintf('got gps string : %s\n',gpsStr);
      case 34 %imu
        imu.tuc  = typecast(packet(6:9),'uint32');
        imu.id   = double(packet(10));
        imu.cntr = double(packet(11));
        imu.rpy  = double(typecast(packet(12:17),'int16')) / 5000; %scaling
        imu.wrpy = double(typecast(packet(18:23),'int16')) / 500;  %scaling
        imu.acc  = double(typecast(packet(24:29),'int16')) / 5000;
%       imu
      case 35 %press + mag
        pmag.id    = double(packet(6));
        pmag.tuc   = typecast(packet(7:10),'uint32');
        pmag.press = double(typecast(packet(11:12),'int16')) + 100000; %pascals
        pmag.temp  = double(typecast(packet(15:16),'int16')) / 100; %deg celcius
        pmag.mag   = double(typecast(packet(19:24),'int16'));
       pmag;
       atan2(pmag.mag(2), pmag.mag(1))
    end
  end
  
end

    
function ret = ReceivePacket()
persistent packetId buf2

if isempty(packetId)
  packetId = kBotPacket2MexAPI('create');
end

ret = [];

if ~isempty(buf2)
  [packet buf2] =  kBotPacket2MexAPI('processBuffer',packetId,buf2);
  if ~isempty(packet)
    ret = packet;
    return;
  end
end

buf = SerialDeviceMexAPI('read',1000,2000);
[packet buf2] = kBotPacket2MexAPI('processBuffer',packetId,buf);
if ~isempty(packet)
  ret = packet;
end
