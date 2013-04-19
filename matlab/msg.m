%
clear all;

state = loadDataMP('../data/stateMP-04.10.2013.17.14.35-0');

pos = zeros(7, size(state,1));
label = zeros(4, size(state, 1));
labelc = 0;
for i = 1 : size(state, 1)
    pos(1, i) = state{i}.x;
    pos(2, i) = state{i}.y;
    pos(3, i) = state{i}.z;
    pos(4, i) = state{i}.timestamp;
    Q = double([state{i}.q0, state{i}.q1, state{i}.q2, state{i}.q3]);
    [yaw pitch roll] = quat2angle(Q);
    pos(5, i) = roll;
    pos(6, i) = pitch;
    pos(7, i) = yaw;

%     if state{i}.label ~= 3
%         labelc = labelc + 1;
%         label(1, labelc) = state{i}.x;
%         label(2, labelc) = state{i}.y;
%         label(3, labelc) = state{i}.label;
%         label(4, labelc) = state{i}.timestamp;
%     end
end

%%
gps = loadDataMP('../data/010213180304.00/gpsLocalMP');

gpspos = zeros(5, size(gps,1));
% gpslabel = zeros(4, size(state, 1));
% gpslabelc = 0;
for i = 1 : size(gps, 1)
    gpspos(1, i) = gps{i}.x;
    gpspos(2, i) = gps{i}.y;
    gpspos(3, i) = gps{i}.z;
    gpspos(4, i) = gps{i}.timestamp;
    if isfield(gps{i}, 'nspeed') 
      gpspos(5, i) = gps{i}.nspeed;
      gpspos(6, i) = gps{i}.truecourse;
    else 
      gpspos(5, i) = 0;
      gpspos(6, i) = 0;
    end
%     gpspos(7, i) = gps{i}.label;
%     if gps{i}.label ~= 3
%         gpslabelc = gpslabelc + 1;
%         gpslabel(1, gpslabelc) = gps{i}.x;
%         gpslabel(2, gpslabelc) = gps{i}.y;
%         gpslabel(3, gpslabelc) = gps{i}.label;
%         gpslabel(4, gpslabelc) = gps{i}.timestamp;
%     end
end

%
% label = label(:, 1 : labelc);
% 
% plot(pos(1,:), pos(2,:), 'y.');
% hold on;
% plot(gpspos(1,:), gpspos(2,:), 'r.');
% plot(gpslabel(1,:), gpslabel(2,:), 'm^');
% plot(label(1,:), label(2,:), 'b*');
% hold off;
% grid on;
% axis equal;

%%
imu = loadDataMP('../data/150213185940.20/imuwlabelBinaryMP');

imudata = zeros(10, size(imu, 1));
for i = 1: size(imu, 1) 
    imudata(1, i) = imu{i}.ax;
    imudata(2, i) = imu{i}.ay;
    imudata(3, i) = imu{i}.az;
    imudata(4, i) = imu{i}.wr;
    imudata(5, i) = imu{i}.wp;
    imudata(6, i) = imu{i}.bwy;
    imudata(7, i) = imu{i}.r;
    imudata(8, i) = imu{i}.p;
    imudata(9, i) = imu{i}.y;
    imudata(10, i) = imu{i}.timestamp;
    imudata(11, i) = imu{i}.label;
end

% %%
% filename = '../data/150213185940.20/headingMP';
% 
% tic;
% fid = fopengeneric(filename);
% data = fread(fid, '*uint8');
% mag = msgpack('unpacker', data);
% toc;
% 
% magdata = zeros(2, size(mag, 1));
% for i = 1: size(mag, 1) 
%     magdata(1, i) = mag{i}.heading;
%     magdata(2, i) = mag{i}.timestamp;
% end

%%
imu = loadDataMP('../data/010213180304.00/estimateMP');
imudata = zeros(10, size(imu, 1));
for i = 1: size(imu, 1) 
    imudata(1, i) = imu{i}.ax;
    imudata(2, i) = imu{i}.ay;
    imudata(3, i) = imu{i}.az;
    imudata(4, i) = imu{i}.wr;
    imudata(5, i) = imu{i}.wp;
    imudata(6, i) = imu{i}.wy;
    imudata(7, i) = imu{i}.r;
    imudata(8, i) = imu{i}.p;
    imudata(9, i) = imu{i}.y;
    imudata(10, i) = imu{i}.timestamp;
%     imudata(11, i) = imu{i}.label;
%     if iscell(imu{i}.alpha)
%     alpha = double([imu{i}.alpha{1},...
%                     imu{i}.alpha{2},...
%                     imu{i}.alpha{3}]);
%     else
%     alpha = double([imu{i}.alpha(1),...
%                     imu{i}.alpha(2),...
%                     imu{i}.alpha(3)]);
%     end
%     [C, I] = max(alpha);
%     imudata(12, i) = I;
end

%%
gps = loadDataMP('../data/010213180304.00/gpsLocalMP');
gpspos = zeros(5, size(gps,1));
for i = 1 : size(gps, 1)
    gpspos(1, i) = gps{i}.x;
    gpspos(2, i) = gps{i}.y;
    gpspos(3, i) = gps{i}.z;
    gpspos(4, i) = gps{i}.timestamp;
%     gpspos(5, i) = gps{i}.predict;
end

