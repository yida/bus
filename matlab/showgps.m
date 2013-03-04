%% Load data
% clear all;
% close all;
% %/Users/Yida/Projects/UPennTHOR/Tools/Matlab/util/
% addpath( genpath('/Users/Yida/Projects/UPennTHOR/Tools/Matlab/util') )
% addpath( genpath('/Users/Yida/Projects/UPennTHOR/Tools/Matlab') )
% %addpath( genpath('/home/yida/UPennTHOR/Tools/Matlab/util') )
% %addpath( genpath('/home/yida/UPennTHOR/Tools/Matlab') )
% 
% 
% h = {};
% h.tid = 1;
% h.pid = 1;
% h.user = getenv('USER');
% 
% h.gps  = shm(sprintf('ucmGps%d%d%s',  h.tid, h.pid, h.user));
% 
% rpy = zeros(1, 3);
% counter = 0;
% dcounter = 0;
% gps = zeros(1, 3);
% gpscount = 1;
%  while (1)
%      cnt = h.gps.get_counter();
%      if cnt ~= counter
%         counter = cnt;
%         pos = h.gps.get_pos();
%         gps(gpscount, :) = [pos(1), pos(2), pos(3)];
%         gpscount = gpscount + 1;
%      end
%  end

 %%
 
 plot(gps(:,1), gps(:, 2),'.');
 axis equal;
 grid on;