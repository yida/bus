clear all;
close all;

bus = {};
bus.name = 'rectangle';
bus.cx = 3.5;
bus.cy = -4;
bus.theta = 0;
bus.w = 2.26;
bus.h = 6.78;
bus.color = 'b';

%busCenter = [0.5, 1.9];
busCenter = [3.5, -4];

  OBJECT = {};
%  OBJECT{1} = struct('name','line', 'a', 0, 'b', 2.8, 'c', 1);
%  OBJECT{2} = struct('name','line', 'a', 1, 'b', 1, 'c', 0);
%  OBJECT{3} = struct('name','line', 'a', 2/3, 'b', 3, 'c', 1);
%  OBJECT{4} = struct('name', 'circle', 'cx', 0.5, 'cy', 2.1, 'r', 0.06);
%  OBJECT{5} = struct('name', 'rectangle', 'cx', 0.5, 'cy', 2.6, 'theta', pi/3,'w', 0.4, 'h', 0.8);
%  OBJECT{6} = struct('name', 'rectangle', 'cx', -1.2, 'cy', 1.5, 'theta', pi/3,'w', 0.4, 'h', 0.8);


startP = [bus.cx, bus.cy];
endP = [bus.cx, bus.cy + 20];

timeStamp = 10;
dt = 1 / timeStamp;
u_s = 2.235; % m/s -> 5mph
u_phi = 0.424;% rad/s, with min turning radius 13.4
L = 6.05;

time = 10;
maxStamp = 100;
for t = 1 : time * timeStamp
%  bus.theta = timeStamp / 100 * pi;
%for busTheta = 0 : pi/100 : pi/2 
  bus.theta = bus.theta + u_s / L * tan(u_phi) * dt;
  bus.cy = bus.cy + u_s * cos(bus.theta) * dt;
  bus.cx = bus.cx + u_s * sin(bus.theta) * dt;

%  [axisRange, Ver] = plot_bus(busCenter, busTheta);
  bus.ver = plot_rectangle(bus);
  hold on;

%  % line 3
%  plot([0, -1.5], [3, 2]);
%  % line 1
%  plot([-3, 3], [2.8, 2.8]);
%  % line 2
%  plot([-1, -1], [0, 4]);
%  % circle 1
%  plot_circle(OBJECT{4});
%  % rectangle
%  plot_rectangle(OBJECT{5});
%  plot_rectangle(OBJECT{6});
%   
%  axisGain = 3.3;
    
%  axis(axisRange.*[1/axisGain, axisGain, 1/axisGain, axisGain]);
  
  object = OBJECT;
  lidar1 = lidar(bus.theta, bus.ver(1,:));
  lidar1 = intersectCal(lidar1, object);
  plot_lidar(lidar1);
%  lidar2 = lidar(busTheta - 3/2*pi, Ver(2,:));
%  plot_lidar(lidar2);



  plot_intersection();
  axis([-25, 25, -25, 25]);

  hold off;
  
  axis equal;
  grid on;
  
  pause(0.2);
end

drawnow;
