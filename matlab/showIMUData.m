addpath('quadrotor_ukf');

%load datamat/20121221route42r1imu.mat
%imuSize = size(imuData, 2);
%
%tuc = 0;
%tucCount = 0;
%imu = {};
%for i = 1 : imuSize
%  imuData{i};
%  imuData{i}.acc;
%  imuData{i}.rpy;
%  imuData{i}.wrpy;
%  if (imuData{i}.tuc ~= tuc)
%    tucCount = tucCount + 1;
%    imu{tucCount} = imuData{i};
%    tuc = imuData{i}.tuc;
%    fprintf(1, '%d %10f\n', imuData{i}.tuc, imuData{i}.tstamp);
%  end
%end

%clear imuData;
%

%{
imuSize = size(imu, 2);
acc = zeros(3, imuSize);
rpy = zeros(3, imuSize);
wrpy = zeros(3, imuSize);
for i = 1 : imuSize - 1
  acc(:, i) = imu{i}.acc;
  rpy(:, i) = imu{i}.rpy;
  wrpy(:, i) = imu{i}.wrpy;
end
figure; plot(1:imuSize, wrpy(1, 1:imuSize), 1:imuSize, wrpy(2, 1:imuSize), 1:imuSize, wrpy(3, 1:imuSize));
figure; plot(1:imuSize, rpy(1, 1:imuSize), 1:imuSize, rpy(2, 1:imuSize), 1:imuSize, rpy(3, 1:imuSize));
figure; plot(1:imuSize, acc(1, 1:imuSize), 1:imuSize, acc(2, 1:imuSize), 1:imuSize, acc(3, 1:imuSize));
%}


%% UKF parameters
alpha = 0.4;
beta = 2.0;
kappa = 0.0;

acc_noise = [0.2, 0.2, 0.2];
w_noise = [0.1, 0.1, 0.1];

acc_bias = [0.02, 0.02, 0.02];
pitch_bias = 0.005;
roll_bias = 0.005;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ukfhandle = mexukf('init', alpha, beta, kappa,...
            acc_noise, w_noise, acc_bias, pitch_bias, roll_bias);


imuSize = size(imu, 2);

for i = 1 : imuSize - 1
  time_str = epoch2date(imu{i}.tstamp)
  [timestamp, pose, orien, v, w, poseCov, twistCov] = mexukf('imu', ukfhandle, [imu{i}.acc* 9.8; imu{i}.wrpy], imu{i}.tstamp); 
%  pause(imu{i+1}.tstamp - imu{i}.tstamp);
end


