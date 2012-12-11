addpath('quadrotor_ukf');

dataload;

nitem = size(imuts,2);

%% acc and gyro conversion

AccSen = 330; % correspond to 3.3V
GyrSen = 3.33;

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

%% synchronize time stamp
minVal = 1000;
minid = -1;
diff = size(imuts,2) - size(viconts,2);
for cnt = 1:diff
    DIFF = sum(abs(imuts(cnt:(cnt+size(viconts,2)-1)) - viconts))
    if DIFF < minVal
        minVal = DIFF;
        minid = cnt;
    end
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

%nAcc = size(R,3);
nVicon = size(rots,3);
%fig = figure(1);
minid
for cnt = 900:nVicon
%    subplot(1,2,1);
% imuts(cnt+minid-1) - viconts(cnt)
%  mexukf('imu', ukfhandle, phyVals(1:6,cnt+minid-1)/10^4, imuts(cnt+minid-1)); 
%  mexukf('vicon', ukfhandle, rots(:,:,cnt),viconts(cnt));
%    rotplotT(rots(:,:,cnt),viconts(cnt));
%    subplot(1,2,2);
%    rotplotT(R(:,:,cnt+minid-1),imuts(cnt+minid-1)); 
end

