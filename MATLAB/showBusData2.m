function showBusData2()

addpath('ReceiveImu');

global imuData;

imurpy = zeros(3, size(imuData,2));

for Sample = 32460 : size(imuData,2) 
  imurpy(:, Sample) = imuData{Sample}.rpy;
%  R = rotz(imuData{Sample}.rpy(3,1))*roty(imuData{Sample}.rpy(2,1))*rotx(imuData{Sample}.rpy(1,1))
%  rotplot(R(1:3,1:3), imuData{Sample}.tstamp);
end

plot(32460:size(imuData,2), imurpy(1,32460:end),...
    32460:size(imuData,2), imurpy(2,32460:end),...
    32460:size(imuData,2), imurpy(3,32460:end));
legend();

% Task 1 : Make time variant plot, like a animation 

% Task 2 : Use Ax, Ay, Az to get rotation matrix with / without Kalman Filter
