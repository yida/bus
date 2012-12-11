clear all;
close all;

loaded = 1;
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
%{
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
%}

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

masksmall = zeros(1, largesize + 2 * smallsize - 2);
masksmall(1, minid:minid + smallsize - 1) = ones(1, smallsize);
mask = masksmall .* masklarge;


%for cnt = 1 : abs(diff)
%  DIFF = mean(abs(large(cnt:(cnt+size(small,2)-1)) - small));
%  if DIFF < minVal
%    minVal = DIFF;
%    minid = cnt;
%  end
%end
minVal
minid

%%
%view raw acc rotation

%nAcc = size(R,3);
nVicon = size(rots,3);
nImu = size(imuts, 2);
%fig = figure(1);
%for cnt = 1 : nImu
%    cnt
%    subplot(1,2,1);
%    rotplotT(rots(:,:,cnt),viconts(cnt));
%    subplot(1,2,2);
%    rotplotT(R(:,:,cnt+minid-1),imuts(cnt+minid-1)); 
%end


