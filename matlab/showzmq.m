clear all;
include;

s1 = zmq('subscribe', 'state');
s2 = zmq('subscribe', 'imu');

data = [];

rpy = zeros(1, 3);
counter = 0;
labelcounter = 0;
dcounter = 0;
while (1)
    [data, idx] = zmq('poll', 100);
    if numel(data) > 0 
      state = msgpack('unpack', data{1});
      cnt = state.counter;
%      labelcnt = h.label.get_counter();
      if cnt ~= counter
         counter = cnt;
         dcounter = dcounter + 1;
%         Q = state.q;
%         [yaw pitch roll] = quat2angle(Q);
         pos = state.pos;
%         R = rotz(yaw)*roty(pitch)*rotx(roll);
%          plot3(pos(1), pos(2), pos(3)*100, '.');
         plot(pos(1), pos(2), 'm.');
         hold on;
         grid on;
         axis equal;
%           subplot(1,2,1)
%          coord(pos(1), pos(2), pos(3), R(1:3, 1:3), magheading);
%          hold on;
%         rotplotT(R(1:3, 1:3), tstep);
%           subplot(1,2,2)jkk
%           rotplotT(tR(1:3, 1:3), tstep);
      end
%      if labelcnt ~= labelcounter
%         value = h.label.get_value();
%         if value == 1
%             plot(pos(1), pos(2), 'b*');
%         elseif value == 2
%             plot(pos(1), pos(2), 'b*');
%         end
%         labelcounter = labelcnt;
%           hold on;
%           grid on;
%           axis equal;
%      end
    drawnow
    end
end


