clear all;
close all;

addpath( genpath('/home/yida/UPennTHOR/Tools/Matlab/utils') )
addpath( genpath('/home/yida/UPennTHOR/Tools/Matlab') )

h = {};
h.tid = 1;
h.pid = 1;
h.user = getenv('USER');

h.ukf  = shm(sprintf('ucmUkf%d%d%s',  h.tid, h.pid, h.user));

rpy = zeros(1, 3);
counter = 0;
dcounter = 0;
 while (1)
     cnt = h.ukf.get_counter();

     if cnt ~= counter
        counter = cnt;
        dcounter = dcounter + 1;
        rpy = h.ukf.get_rpy();
        trpy = h.ukf.get_trpy();
        tstep = h.ukf.get_timestamp();
        R = rotz(rpy(3))*roty(rpy(2))*rotx(rpy(1));
        tR = rotz(trpy(3))*roty(trpy(2))*rotx(trpy(1));
        subplot(1,2,1)
        rotplotT(R(1:3, 1:3), tstep);
        subplot(1,2,2)
        rotplotT(tR(1:3, 1:3), tstep);
     end
 end

% for i = 1 : size(rpy, 1)
% R = rotz(rpy(i,3))*roty(rpy(i, 2))*rotx(rpy(i, 1));
% rotplotT(R(1:3, 1:3), 453443);
% end
