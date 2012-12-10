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

 figure; plot(1:nitem,phyVals(1,:),1:nitem,phyVals(2,:),1:nitem,phyVals(3,:));
 figure; plot(1:nitem,phyVals(4,:),1:nitem,phyVals(5,:),1:nitem,phyVals(6,:));

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
minVal = 1000;
minid = -1;
diff = size(imuts,2) - size(viconts,2);
for cnt = 1:diff
    DIFF = sum(abs(imuts(cnt:(cnt+size(viconts,2)-1)) - viconts));
    if DIFF < minVal
        minVal = DIFF;
        minid = cnt;
    end
end

%%
%view raw acc rotation

nAcc = size(R,3);
nVicon = size(rots,3);
fig = figure(1);
for cnt = 900:nVicon
    cnt
    subplot(1,2,1);
    rotplotT(rots(:,:,cnt),viconts(cnt));
    subplot(1,2,2);
    rotplotT(R(:,:,cnt+minid-1),imuts(cnt+minid-1)); 
end


