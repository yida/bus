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
imuFile(loaded).name
load(strcat(dataPath,imuFile(loaded).name));
imuts = ts;

% load vicon
viconFile(loaded).name
load(strcat(dataPath,viconFile(loaded).name));
viconts = ts;

%if camOn
%    load(strcat(dataPath,camFile(loaded).name));
%    camts = ts;
%end

clear ts;


