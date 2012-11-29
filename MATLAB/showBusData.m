function showBusData(syncData)

if nargin < 1
  fprintf('Must input syncData\n');
  return;
end

addpath('ReceiveImu');

% timeStamp, time, Lat, NS, Lon, EW, Alti, r, p ,y, Gx, Gy, Gz, Ax, Ay, Az, Label
tStamp = syncData(1,:);
r  = syncData(8,:);
p  = syncData(9,:);
y  = syncData(10,:);
Gx = syncData(11,:);
Gy = syncData(12,:);
Gz = syncData(13,:);
Ax = syncData(14,:);
Ay = syncData(15,:);
Az = syncData(16,:);

for Sample = 1 : size(tStamp,2) 
  R = rotz(y(1,Sample))*roty(p(1,Sample))*rotx(r(1,Sample));
  rotplot(R(1:3,1:3), tStamp(1,Sample));
end

% Task 1 : Make time variant plot, like a animation 

% Task 2 : Use Ax, Ay, Az to get rotation matrix with / without Kalman Filter
