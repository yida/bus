clear all;
close all;

%datapath = '../data/philadelphia/211212164337.00/';
%datapath = '../data/philadelphia/211212165622.00/';
%datapath = '../data/philadelphia/191212190259.60/';
%datapath = '../data/philadelphia/010213180304.00/';

%datapath = '../data/philadelphia/150213185940.20-1/';
%datapath = '../data/philadelphia/150213185940.20-2/';
%datapath = '../data/philadelphia/010213180304.00-1/';
%datapath = '../data/philadelphia/010213180304.00-2/';
datapath = '../data/philadelphia/260713142751.40/';
datapath = '../data/philadelphia/260713145217.80/';
datapath = '../data/philadelphia/260713153413.60/';

gps = load_data_msgpack([datapath, 'gpsLocalMP']);
label = load_data_msgpack([datapath, 'labelPrunedMP']);
%label = load_data_msgpack([datapath, 'labelMP']);
imu = load_data_msgpack([datapath, 'imuPrunedMP']);
%mag = load_data_msgpack([datapath, 'magPrunedMP']);

load([datapath, 'map_shift.mat']);

