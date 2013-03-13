clear all;
close all;
%/Users/Yida/Projects/UPennTHOR/Tools/Matlab/util/
% addpath( genpath('/Users/Yida/Projects/UPennTHOR/Tools/Matlab/util') )
% addpath( genpath('/Users/Yida/Projects/UPennTHOR/Tools/Matlab') )
addpath( genpath('/home/yida/UPennTHOR/Tools/Matlab/util') )
addpath( genpath('/home/yida/UPennTHOR/Tools/Matlab') )


h = {};
h.tid = 1;
h.pid = 1;
h.user = getenv('USER');

h.ukf  = shm(sprintf('ucmUkf%d%d%s',  h.tid, h.pid, h.user));
h.label  = shm(sprintf('ucmLabel%d%d%s',  h.tid, h.pid, h.user));

rpy = zeros(1, 3);
counter = 0;
labelcounter = 0;
dcounter = 0;
 while (1)
     cnt = h.ukf.get_counter();
     labelcnt = h.label.get_counter(); 
     if cnt ~= counter
        counter = cnt;
        dcounter = dcounter + 1;
        Q = h.ukf.get_quat();
        [yaw pitch roll] = quat2angle(Q);
        trpy = h.ukf.get_trpy();
        tstep = h.ukf.get_timestamp();
        magheading = h.ukf.get_magheading();
        pos = h.ukf.get_pos();
        R = rotz(yaw)*roty(pitch)*rotx(roll);
        tR = rotz(trpy(3))*roty(trpy(2))*rotx(trpy(1));
%         plot3(pos(1), pos(2), pos(3), '*');
        plot(pos(1), pos(2), '.');
        hold on;
        grid on;
%         subplot(1,2,1)
%        coord(pos(1), pos(2), pos(3), R(1:3, 1:3), magheading);
%        hold on;
%       rotplotT(R(1:3, 1:3), tstep);
%         subplot(1,2,2)jkk
%         rotplotT(tR(1:3, 1:3), tstep);
     end
     if labelcnt ~= labelcounter
        plot(pos(1), pos(2), 'ro');
        labelcounter = labelcnt;
     end
     drawnow
 end

% for i = 1 : size(rpy, 1)
% R = rotz(rpy(i,3))*roty(rpy(i, 2))*rotx(rpy(i, 1));
% rotplotT(R(1:3, 1:3), 453443);
% end
