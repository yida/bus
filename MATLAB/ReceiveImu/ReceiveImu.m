function ReceiveImu()
clear all;
close all;

global rawVals rawCntr


dev  = '/dev/ttyUSB0';
baud = 230400;
SerialDeviceAPI('connect',dev,baud);

while(1)
  %fprintf('.');
  packet = ReceivePacket();
  if ~isempty(packet)
    id   = packet(3);
    type = packet(5);
    
    fprintf('got packet %d %d\n',id,type);
    
    if (id == 0) %LL
      if (type == 0)
      
      elseif (type == 1)
        imuVals = double(typecast(packet(10:end-1),'single'))
        R = rotz(imuVals(3))*roty(imuVals(2))*rotx(imuVals(1));
      end
    end
  end
end

    
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