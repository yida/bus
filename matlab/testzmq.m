clear all;
s1 = zmq('subscribe','state');
data = [];
while (true)
  [data,idx] = zmq('poll',100);
  if numel(data) > 0
    state = msgpack('unpack', data{1});
    [yaw pitch roll] = quat2angle(double([state.q0, state.q1,...
                                            state.q2, state.q3]));
    R = rotz(yaw)*roty(pitch)*rotx(roll);
    rotplotT(R(1:3, 1:3),0);
    grid on;
  end
  drawnow;
end