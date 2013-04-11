filename = './bus/bus/imuPrunedMP';

tic;
fid = fopengeneric(filename);
data = fread(fid, '*uint8');
imu = msgpack('unpacker', data);
toc;

filename = './bus/bus/gpsMP';

tic;
fid = fopengeneric(filename);
data = fread(fid, '*uint8');
gps = msgpack('unpacker', data);
toc;

filename = './bus/bus/labelMP';

tic;
fid = fopengeneric(filename);
data = fread(fid, '*uint8');
label = msgpack('unpacker', data);
toc;

filename = './bus/bus/magPrunedMP';

tic;
fid = fopengeneric(filename);
data = fread(fid, '*uint8');
mag = msgpack('unpacker', data);
toc;