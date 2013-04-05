clear all;
close all;
addpath( genpath('.'))
%/Users/Yida/Projects/UPennTHOR/Tools/Matlab/util/
if ismac
addpath( genpath('/Users/Yida/Projects/UPennTHOR/Tools/Matlab/util') )
addpath( genpath('/Users/Yida/Projects/UPennTHOR/Tools/Matlab') )
else
addpath( genpath('/home/yida/UPennTHOR/Tools/Matlab/util') )
addpath( genpath('/home/yida/UPennTHOR/Tools/Matlab') )
end

h = {};
h.tid = 1;
h.pid = 1;
h.user = getenv('USER');

h.ukf  = shm(sprintf('ucmUkf%d%d%s',  h.tid, h.pid, h.user));
h.label  = shm(sprintf('ucmLabel%d%d%s',  h.tid, h.pid, h.user));

rpy = zeros(1, 3);
counter = h.ukf.get_counter();
labelcounter = h.label.get_counter();
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
%        plot3(pos(1), pos(2), pos(3)*100, '.');
%        plot(pos(1), pos(2), 'm.');
%         hold on;
        grid on;
        axis equal;
%         subplot(1,2,1)
%        coord(pos(1), pos(2), pos(3), R(1:3, 1:3), magheading);
%        hold on;
       rotplotT(R(1:3, 1:3), tstep);
%         subplot(1,2,2)jkk
%         rotplotT(tR(1:3, 1:3), tstep);
     end
     if labelcnt ~= labelcounter
        value = h.label.get_value();
        if value == 1
            plot(pos(1), pos(2), 'b*');
        elseif value == 2
            plot(pos(1), pos(2), 'b*');
        end
        labelcounter = labelcnt;
%         hold on;
%         grid on;
%         axis equal;
     end
     drawnow
 end

% for i = 1 : size(rpy, 1)
% R = rotz(rpy(i,3))*roty(rpy(i, 2))*rotx(rpy(i, 1));
% rotplotT(R(1:3, 1:3), 453443);
% end
