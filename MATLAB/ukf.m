clear all;
close all;

addpath('quadrotor_ukf');

loaded = 3;
dataload;

% % view vicon rotation
% nVicon = size(rots,3);
% fig = figure(1);
% for cnt = 1:nVicon
%    rotplot(rots(:,:,cnt),viconts(cnt)); 
% end
% 
nitem = size(imuts,2);

%% acc and gyro conversion

AccSen = 330; % correspond to 3.3V
GyrSen = 3.33;

%% Before conversion
% figure;plot(imuts,vals(1,:),imuts,vals(2,:),imuts,vals(3,:));
% figure;plot(imuts,vals(4,:),imuts,vals(5,:),imuts,vals(6,:));

%% compute bias
bias = zeros(6,1);
% Ax bias
bias(1) = mean(vals(1,1:100));
% Ay Bias 
bias(2) = mean(vals(2,1:100));
% Az Bias
bias(3) = mean(vals(3,1:100)) - 98000 / AccSen / 3300 * 1023;
% Wz Bias
bias(4) = mean(vals(4,1:100));
% Wx Bias
bias(5) = mean(vals(5,1:100));
% Wy Bias
bias(6) = mean(vals(6,1:100));


phyVals = zeros(size(vals));
phyVals(1:3,:) = bsxfun(@minus,vals(1:3,:),bias(1:3)) * 3300 / 1023 * AccSen;
phyVals(4:6,:) = bsxfun(@minus,vals(4:6,:),bias(4:6)) * 3300 / 1023 * GyrSen * pi / 180;

%figure; plot(1:nitem,phyVals(1,:),1:nitem,phyVals(2,:),1:nitem,phyVals(3,:));
%figure; plot(1:nitem,phyVals(4,:),1:nitem,phyVals(5,:),1:nitem,phyVals(6,:));

%% Acc to Rotation

cyaw = -phyVals(2,:)./sqrt(phyVals(1,:).^2 + phyVals(2,:).^2);
cyaw(isnan(cyaw)) = 1;
syaw = -phyVals(1,:)./sqrt(phyVals(1,:).^2 + phyVals(2,:).^2);
syaw(isnan(syaw)) = 0;

cpitch = phyVals(3,:)./sqrt(phyVals(1,:).^2 + phyVals(3,:).^2);
cpitch(isnan(cpitch)) = 1;
spitch = -phyVals(1,:)./sqrt(phyVals(1,:).^2 + phyVals(3,:).^2);
spitch(isnan(spitch)) = 0;

sroll = phyVals(2,:)./sqrt(phyVals(2,:).^2 + phyVals(3,:).^2);
sroll(isnan(sroll)) = 0;
croll = phyVals(3,:)./sqrt(phyVals(2,:).^2 + phyVals(3,:).^2);
croll(isnan(croll)) = 1;



%%
R = zeros(3,3,size(cyaw,2));
R(1,1,:) = cyaw.*cpitch;
R(1,2,:) = croll.*syaw+cyaw.*spitch.*sroll;
R(1,3,:) = syaw.*sroll-cyaw.*croll.*spitch;
R(2,1,:) = -cpitch.*syaw;
R(2,2,:) = cyaw.*croll-syaw.*spitch.*sroll;
R(2,3,:) = cyaw.*sroll+croll.*syaw.*spitch;
R(3,1,:) = spitch;
R(3,2,:) = -cpitch.*sroll;
R(3,3,:) = cpitch.*croll;

%% synchronize time stamp
minVal = 1;
minid = -1;
diff = size(imuts,2) - size(viconts,2);
flag = 0;
if (diff < 0) 
  flag = 1;
  large = viconts;
  small = imuts;
else
  flag = -1;
  large = imuts;
  small = viconts;
end  


largesize = size(large, 2);
smallsize = size(small, 2);

masklarge = zeros(1, largesize + 2 * smallsize - 2);
masklarge(1, smallsize : smallsize + largesize - 1) = ones(1, largesize);
masksmall = zeros(1, largesize + 2 * smallsize - 2);
minid = -1;
minVal = 1;
for count = 1 : (size(masklarge, 2) - smallsize + 1)
  masksmall = zeros(1, largesize + 2 * smallsize - 2);
  masksmall(1, count:count + smallsize - 1) = ones(1, smallsize);
  mask = masksmall .* masklarge;

  largeVal = zeros(1, largesize + 2 * smallsize - 2); 
  largeVal(smallsize : smallsize + largesize - 1) = large;
  smallVal = zeros(1, largesize + 2 * smallsize - 2); 
  smallVal(count:count + smallsize - 1) = small;
  DIFF = mean(abs(largeVal.*mask - smallVal.*mask));
  if DIFF < minVal
    minVal = DIFF;
    minid = count;
  end
end

if (minid - smallsize + 1) < 1 
  smallbegin = smallsize - minid;
  smallend = smallsize;
  length = smallend - smallbegin;
  largebegin = 1;
  largeend = largebegin + length - 1;
else
  smallbegin = 1;
  largebegin = minid - smallsize;
  length = min(smallsize - smallbegin + 1, largesize - largebegin);
  smallend = smallbegin + length - 1;
  largeend = largesize + length - 1;
end

if (flag > 0) % imu small vicon large
  imubegin = smallbegin;
  imuend = smallend;
  %length
  viconbegin = largebegin;
  viconend = largeend;
else
  imubegin = largebegin;
  imuend = largeend;
  viconbegin = smallbegin;
  viconend = smallend;
end

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

%% UKF Initial
ukfhandle = mexukf('init', alpha, beta, kappa,...
            acc_noise, w_noise, acc_bias, pitch_bias, roll_bias);

%[timestamp, pose, orien(ypr), v, w, poseCov, twistCov] = mexukf('imu', ....);

for cnt = 0 : length - 1
%    subplot(1,2,1);
% imuts(cnt+minid-1) - viconts(cnt)
  [timestamp, pose, orien, v, w, poseCov, twistCov] = mexukf('imu', ukfhandle, phyVals(1:6,imubegin+cnt)/10^4, imuts(imubegin+cnt)); 
  mexukf('vicon', ukfhandle, rots(:,:,viconbegin+cnt),viconts(viconbegin+cnt));
  if timestamp ~= 0
    timestamp
    pose
  end
%    rotplotT(rots(:,:,cnt),viconts(cnt));
%    subplot(1,2,2);
%    rotplotT(R(:,:,cnt+minid-1),imuts(cnt+minid-1)); 
end

