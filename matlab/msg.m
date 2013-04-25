%
clear all;
close all;

%state = loadDataMP('../data/stateMP-04.10.2013.17.14.35-0');
%
%pos = zeros(7, size(state,1));
%label = zeros(4, size(state, 1));
%labelc = 0;
%for i = 1 : size(state, 1)
%    pos(1, i) = state{i}.x;
%    pos(2, i) = state{i}.y;
%    pos(3, i) = state{i}.z;
%    pos(4, i) = state{i}.timestamp;
%    Q = double([state{i}.q0, state{i}.q1, state{i}.q2, state{i}.q3]);
%    [yaw pitch roll] = quat2angle(Q);
%    pos(5, i) = roll;
%    pos(6, i) = pitch;
%    pos(7, i) = yaw;
%
%%     if state{i}.label ~= 3
%%         labelc = labelc + 1;
%%         label(1, labelc) = state{i}.x;
%%         label(2, labelc) = state{i}.y;
%%         label(3, labelc) = state{i}.label;
%%         label(4, labelc) = state{i}.timestamp;
%%     end
%end
%
%%%
%gps = loadDataMP('../data/010213180304.00/gpsLocalMP');
%
%gpspos = zeros(5, size(gps,1));
%% gpslabel = zeros(4, size(state, 1));
%% gpslabelc = 0;
%for i = 1 : size(gps, 1)
%    gpspos(1, i) = gps{i}.x;
%    gpspos(2, i) = gps{i}.y;
%    gpspos(3, i) = gps{i}.z;
%    gpspos(4, i) = gps{i}.timestamp;
%    if isfield(gps{i}, 'nspeed') 
%      gpspos(5, i) = gps{i}.nspeed;
%      gpspos(6, i) = gps{i}.truecourse;
%    else 
%      gpspos(5, i) = 0;
%      gpspos(6, i) = 0;
%    end
%%     gpspos(7, i) = gps{i}.label;
%%     if gps{i}.label ~= 3
%%         gpslabelc = gpslabelc + 1;
%%         gpslabel(1, gpslabelc) = gps{i}.x;
%%         gpslabel(2, gpslabelc) = gps{i}.y;
%%         gpslabel(3, gpslabelc) = gps{i}.label;
%%         gpslabel(4, gpslabelc) = gps{i}.timestamp;
%%     end
%end
%
%%
%% label = label(:, 1 : labelc);
%% 
%% plot(pos(1,:), pos(2,:), 'y.');
%% hold on;
%% plot(gpspos(1,:), gpspos(2,:), 'r.');
%% plot(gpslabel(1,:), gpslabel(2,:), 'm^');
%% plot(label(1,:), label(2,:), 'b*');
%% hold off;
%% grid on;
%% axis equal;
%
%%%
%imu = loadDataMP('../data/150213185940.20/imuwlabelBinaryMP');
%
%imudata = zeros(10, size(imu, 1));
%for i = 1: size(imu, 1) 
%    imudata(1, i) = imu{i}.ax;
%    imudata(2, i) = imu{i}.ay;
%    imudata(3, i) = imu{i}.az;
%    imudata(4, i) = imu{i}.wr;
%    imudata(5, i) = imu{i}.wp;
%    imudata(6, i) = imu{i}.bwy;
%    imudata(7, i) = imu{i}.r;
%    imudata(8, i) = imu{i}.p;
%    imudata(9, i) = imu{i}.y;
%    imudata(10, i) = imu{i}.timestamp;
%    imudata(11, i) = imu{i}.label;
%end
%
%% %%
%% filename = '../data/150213185940.20/headingMP';
%% 
%% tic;
%% fid = fopengeneric(filename);
%% data = fread(fid, '*uint8');
%% mag = msgpack('unpacker', data);
%% toc;
%% 
%% magdata = zeros(2, size(mag, 1));
%% for i = 1: size(mag, 1) 
%%     magdata(1, i) = mag{i}.heading;
%%     magdata(2, i) = mag{i}.timestamp;
%% end
%
%%%
%imu = loadDataMP('../data/010213180304.00/estimateMP');
%imudata = zeros(10, size(imu, 1));
%for i = 1: size(imu, 1) 
%    imudata(1, i) = imu{i}.ax;
%    imudata(2, i) = imu{i}.ay;
%    imudata(3, i) = imu{i}.az;
%    imudata(4, i) = imu{i}.wr;
%    imudata(5, i) = imu{i}.wp;
%    imudata(6, i) = imu{i}.wy;
%    imudata(7, i) = imu{i}.r;
%    imudata(8, i) = imu{i}.p;
%    imudata(9, i) = imu{i}.y;
%    imudata(10, i) = imu{i}.timestamp;
%%     imudata(11, i) = imu{i}.label;
%%     if iscell(imu{i}.alpha)
%%     alpha = double([imu{i}.alpha{1},...
%%                     imu{i}.alpha{2},...
%%                     imu{i}.alpha{3}]);
%%     else
%%     alpha = double([imu{i}.alpha(1),...
%%                     imu{i}.alpha(2),...
%%                     imu{i}.alpha(3)]);
%%     end
%%     [C, I] = max(alpha);
%%     imudata(12, i) = I;
%end
%
%%%
%gps = loadDataMP('../data/010213180304.00/gpsLocalMP');
%gpspos = zeros(5, size(gps,1));
%for i = 1 : size(gps, 1)
%    gpspos(1, i) = gps{i}.x;
%    gpspos(2, i) = gps{i}.y;
%    gpspos(3, i) = gps{i}.z;
%    gpspos(4, i) = gps{i}.timestamp;
%%     gpspos(5, i) = gps{i}.predict;
%end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% start_time = 946684969.05;
% end_time =   946688106.02;
% 
% %section_time(1, 1) = 946687357.3764030;
% %section_time(1, 2) = 946687389.4243770;
% %section_time(1, 1) = 946685183.22;
% %section_time(1, 2) = 946685219.19;
% section_time(1, 1) = start_time
% section_time(1, 2) = start_time
% 
% gps = loadDataMP('../data/150213185940.20/gpsLocalCleanMP');
% %gps = loadDataMP('../data/010213180304.00/gpsLocalMP');
% gps_data = zeros(size(gps, 1), 4);
% tic;
% for i = 1 : size(gps, 1)
%   gps_data(i, 1) = gps{i}.x;
%   gps_data(i, 2) = gps{i}.y;
%   gps_data(i, 3) = gps{i}.z;
%   gps_data(i, 4) = gps{i}.timestamp;
% end
% toc;
% gps_idx = find(gps_data(:, 4) <= start_time);
% gps_start_idx = gps_idx(end);
% gps_idx = find(gps_data(:, 4) <= end_time);
% gps_end_idx = gps_idx(end);
% gps_idx = [];
% 
% for i = 1 : size(section_time, 1) 
%     s_time = section_time(i, 1);
%     e_time = section_time(i, 2);
%     idx = find(gps_data(:, 4) <= s_time);
%     start_idx = idx(end);
%     idx = find(gps_data(:, 4) <= e_time);
%     end_idx = idx(end);
% 
%     gps_idx = [gps_idx, gps_start_idx:start_idx];
%     gps_start_idx = end_idx;
% end
% gps_idx = [gps_idx, gps_start_idx:gps_end_idx];
% 
% 
% imu = loadDataMP('../data/150213185940.20/imuPrunedCleanMP');
% % imu = loadDataMP('../data/010213180304.00/imuPrunedMP');
% imu_data = zeros(size(imu, 1), 7);
% tic;
% for i = 1 : size(imu, 1)
%   imu_data(i, 1) = imu{i}.ax;
%   imu_data(i, 2) = imu{i}.ay;
%   imu_data(i, 3) = imu{i}.az;
%   imu_data(i, 4) = imu{i}.wr;
%   imu_data(i, 5) = imu{i}.wp;
%   imu_data(i, 6) = imu{i}.wy;
%   imu_data(i, 7) = imu{i}.timestamp;
% end
% toc;
% imu_idx = find(imu_data(:, 7) <= start_time);
% imu_start_idx = imu_idx(end);
% imu_idx = find(imu_data(:, 7) <= end_time);
% imu_end_idx = imu_idx(end);
% imu_idx = [];
% 
% for i = 1 : size(section_time, 1) 
%     s_time = section_time(i, 1);
%     e_time = section_time(i, 2);
%     idx = find(imu_data(:, 7) <= s_time);
%     start_idx = idx(end);
%     idx = find(imu_data(:, 7) <= e_time);
%     end_idx = idx(end);
% 
%     imu_idx = [imu_idx, imu_start_idx:start_idx];
%     imu_start_idx = end_idx;
% end
% imu_idx = [imu_idx, imu_start_idx : imu_end_idx];
% 
% fig1 = figure;
% plot(gps_data(gps_idx, 1), gps_data(gps_idx, 2), '.');
% grid;
% 
% fig2 = figure;
% tstart = imu_start_idx;
% tend = imu_end_idx;
% plotyy(gps_data(gps_idx, 4),...
%         gps_data(gps_idx, 2),...
%         imu_data(imu_idx, 7),...
%         imu_data(imu_idx, 6));
% %plot(1:tend, imu_data(tstart:tend, 6))
% grid;
% 
% gps_obj = datacursormode(fig1);
% set(gps_obj, 'UpdateFcn', {@datafunction, gps_data, imu_data});
% 
% imu_obj = datacursormode(fig2);
% set(imu_obj, 'UpdateFcn', {@datafunction, gps_data, imu_data});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%imu = loadDataMP('../data/150213185940.20/imuwlabelCleanMP');
%imu_data = zeros(size(imu, 1), 8);
%tic;
%for i = 1 : size(imu, 1)
%  imu_data(i, 1) = imu{i}.ax;
%  imu_data(i, 2) = imu{i}.ay;
%  imu_data(i, 3) = imu{i}.az;
%  imu_data(i, 4) = imu{i}.wr;
%  imu_data(i, 5) = imu{i}.wp;
%  imu_data(i, 6) = imu{i}.wy;
%  imu_data(i, 7) = imu{i}.timestamp;
%  imu_data(i, 8) = imu{i}.label;
%end
%toc;
%
%figure;
%plot(imu_data(:, 7), imu_data(:, 6));
%hold on;
%plot(imu_data(:, 7), imu_data(:, 8));
%hold off;
%grid on;
%
%estimate = loadDataMP('../data/150213185940.20/estimateCleanMP');
%estimate_data = zeros(size(estimate, 1), 8);
%tic;
%for i = 1 : size(estimate, 1)
%  estimate_data(i, 1) = estimate{i}.ax;
%  estimate_data(i, 2) = estimate{i}.ay;
%  estimate_data(i, 3) = estimate{i}.az;
%  estimate_data(i, 4) = estimate{i}.wr;
%  estimate_data(i, 5) = estimate{i}.wp;
%  estimate_data(i, 6) = estimate{i}.wy;
%  estimate_data(i, 7) = estimate{i}.timestamp;
%  estimate_data(i, 8) = estimate{i}.predict;
%  estimate_data(i, 9) = estimate{i}.label;
%end
%toc;
%
%figure;
%plot(estimate_data(:, 7), estimate_data(:, 6),...
%    estimate_data(:, 7), estimate_data(:, 8),...
%    estimate_data(:, 7), 3 * estimate_data(:, 9));
%hold off;
%grid on;


gps = loadDataMP('../data/010213192135.40/gpsLocalMP');
imu = loadDataMP('../data/010213192135.40/imuPrunedMP');
imu_data = zeros(size(imu, 1), 8);
tic;
for i = 1 : size(imu, 1)
  imu_data(i, 1) = imu{i}.ax;
  imu_data(i, 2) = imu{i}.ay;
  imu_data(i, 3) = imu{i}.az;
  imu_data(i, 4) = imu{i}.wr;
  imu_data(i, 5) = imu{i}.wp;
  imu_data(i, 6) = imu{i}.wy;
  imu_data(i, 7) = imu{i}.timestamp;
end
toc;
gps_data = zeros(size(gps, 1), 4);
tic;
for i = 1 : size(gps, 1)
  gps_data(i, 1) = gps{i}.x;
  gps_data(i, 2) = gps{i}.y;
  gps_data(i, 3) = gps{i}.z;
  gps_data(i, 4) = gps{i}.timestamp;
end
toc;

plotyy(gps_data(:, 4), gps_data(:, 2),...
        imu_data(:, 7), imu_data(:, 6));
fig1 = figure;
plot(gps_data(:, 1), gps_data(:, 2), '.');
grid;

