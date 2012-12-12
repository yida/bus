%%
dataPath = '../ESE650-2012/project2/';

imuFile = dir(strcat(dataPath,'imuRaw*.mat'));
viconFile = dir(strcat(dataPath,'viconRot*.mat'));
%camFile = dir(strcat(dataPath,'cam*.mat'));

%% 
% Enable Camera data or not
%camOn = false;

% The imu Data Loaded 
%loaded = 5; 

%% Check available data
%if camOn
%    loaded = min(loaded, size(camFile,1));
%else
%    loaded = min(loaded, size(imuFile,1));
%end
%

%% Load Data
% load imu
imuFilename = strcat('imuRaw',num2str(loaded),'.mat');
load(strcat(dataPath,imuFilename));
imuts = ts;

% load vicon
viconFilename = strcat('viconRot',num2str(loaded),'.mat');
load(strcat(dataPath,viconFilename));
viconts = ts;

%if camOn
%    load(strcat(dataPath,camFile(loaded).name));
%    camts = ts;
%end

clear ts;


