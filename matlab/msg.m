%%
clear all;

filename = '../script/stateMP-03.27.2013.15.49.16-0';

tic;
fid = fopen(filename);
data = fread(fid, '*uint8');
state = msgpack('unpacker', data);
toc;

pos = zeros(4, size(state,1));
label = zeros(4, size(state, 1));
labelc = 0;
for i = 1 : size(state, 1)
    pos(1, i) = state{i}.x;
    pos(2, i) = state{i}.y;
    pos(3, i) = state{i}.z;
    pos(4, i) = state{i}.timestamp;
%     if state{i}.label ~= 3
%         labelc = labelc + 1;
%         label(1, labelc) = state{i}.x;
%         label(2, labelc) = state{i}.y;
%         label(3, labelc) = state{i}.label;
%         label(4, labelc) = state{i}.timestamp;
%     end
end

%%
filename = '../data/150213185940.20/gpswlabelMP-03.26.2013.12.37.43-0';

tic;
fid = fopen(filename);
data = fread(fid, '*uint8');
gps = msgpack('unpacker', data);
toc;

gpspos = zeros(4, size(gps,1));
gpslabel = zeros(4, size(state, 1));
gpslabelc = 0;
for i = 1 : size(gps, 1)
    gpspos(1, i) = gps{i}.x;
    gpspos(2, i) = gps{i}.y;
    gpspos(3, i) = gps{i}.z;
    gpspos(4, i) = gps{i}.timestamp;
    if gps{i}.label ~= 3
        gpslabelc = gpslabelc + 1;
        gpslabel(1, gpslabelc) = gps{i}.x;
        gpslabel(2, gpslabelc) = gps{i}.y;
        gpslabel(3, gpslabelc) = gps{i}.label;
        gpslabel(4, gpslabelc) = gps{i}.timestamp;
    end
end

%%
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
filename = '../data/150213185940.20/imuPrunedMP-03.16.2013.15.30.15-0';

tic;
fid = fopen(filename);
data = fread(fid, '*uint8');
imu = msgpack('unpacker', data);
toc;

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
end

