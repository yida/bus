clear all;
close all;

%datapath = '../data/philadelphia/211212164337.00/';
%datapath = '../data/philadelphia/211212165622.00/';
%datapath = '../data/philadelphia/150213185940.20/';
%datapath = '../data/philadelphia/191212190259.60/';
datapath = '../data/philadelphia/010213180304.00/';

gps = load_data_msgpack([datapath, 'gpsLocalMP']);
label = load_data_msgpack([datapath, 'labelPrunedMP']);
imu = load_data_msgpack([datapath, 'imuPrunedMP']);
%mag = load_data_msgpack([datapath, 'magPrunedMP']);


