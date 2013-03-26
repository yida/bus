%%
clear all;

filename = '../data/150213185940.20/obsCleanMP-03.26.2013.12.31.49-0';

tic;
fid = fopen(filename);
data = fread(fid, '*uint8');
state = msgpack('unpacker', data);
toc;

pos = zeros(3, size(state,1));
label = zeros(3, size(state, 1));
labelc = 0;
for i = 1 : size(state, 1)
    pos(1, i) = state{i}.x;
    pos(2, i) = state{i}.y;
    pos(3, i) = state{i}.z;
    if state{i}.label ~= 3
        labelc = labelc + 1;
        label(1, labelc) = state{i}.x;
        label(2, labelc) = state{i}.y;
        label(3, labelc) = state{i}.label;
    end
end

%%
filename = '../data/150213185940.20/gpswlabelMP-03.26.2013.12.37.43-0';

tic;
fid = fopen(filename);
data = fread(fid, '*uint8');
gps = msgpack('unpacker', data);
toc;

gpspos = zeros(3, size(gps,1));
gpslabel = zeros(3, size(state, 1));
gpslabelc = 0;
for i = 1 : size(gps, 1)
    gpspos(1, i) = gps{i}.x;
    gpspos(2, i) = gps{i}.y;
    gpspos(3, i) = gps{i}.z;
    if gps{i}.label ~= 3
        gpslabelc = gpslabelc + 1;
        gpslabel(1, gpslabelc) = gps{i}.x;
        gpslabel(2, gpslabelc) = gps{i}.y;
        gpslabel(3, gpslabelc) = gps{i}.label;
    end
end

%%
label = label(:, 1 : labelc);

plot(pos(1,:), pos(2,:), 'y.');
hold on;
plot(gpspos(1,:), gpspos(2,:), 'r.');
plot(gpslabel(1,:), gpslabel(2,:), 'm^');
plot(label(1,:), label(2,:), 'b*');
hold off;
grid on;
axis equal;