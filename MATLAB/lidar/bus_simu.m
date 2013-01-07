clear all;
close all;

bus1 = bus(-3.5, -15, 0);

  OBJECT = {};
%  OBJECT{1} = struct('name','line', 'a', 0, 'b', 2.8, 'c', 1);
%  OBJECT{2} = struct('name','line', 'a', 1, 'b', 1, 'c', 0);
%  OBJECT{3} = struct('name','line', 'a', 2/3, 'b', 3, 'c', 1);
%  OBJECT{5} = struct('name', 'rectangle', 'cx', 0.5, 'cy', 2.6, 'theta', pi/3,'w', 0.4, 'h', 0.8);
  OBJECT{1} = struct('name', 'rectangle', 'cx', 4, 'cy', 7, 'theta', 0,'w', 1.766, 'h', 4.703);
  OBJECT{2} = struct('name', 'circle', 'cx', -10, 'cy', 8, 'r', 0.25);
  OBJECT{3} = struct('name', 'circle', 'cx', -11, 'cy', -7, 'r', 0.25);


timeStamp = 10;
dt = 1 / timeStamp;

time = 20;
maxStamp = 100;
for t = 1 : time * timeStamp

  bus1 = busUpdate(bus1, dt);

  bus1.ver = plot_rectangle(bus1);
  hold on;

%  % line 3
%  plot([0, -1.5], [3, 2]);
%  % line 1
%  plot([-3, 3], [2.8, 2.8]);
%  % line 2
%  plot([-1, -1], [0, 4]);
%  % circle 1
  plot_circle(OBJECT{2});
  plot_circle(OBJECT{3});
%  % rectangle
%  plot_rectangle(OBJECT{5});
  plot_rectangle(OBJECT{1});
%   
%  axisGain = 3.3;
    
%  axis(axisRange.*[1/axisGain, axisGain, 1/axisGain, axisGain]);
  
  object = OBJECT;
  lidar1 = lidar(bus1.theta, bus1.ver(1,:));
  lidar1 = intersectCal(lidar1, object);
  plot_lidar(lidar1);

%  lidar2 = lidar(bus1.theta - 3/2*pi, bus1.ver(2,:));
%  lidar2 = intersectCal(lidar2, object);
%  plot_lidar(lidar2);



  plot_intersection();

  C = clock();
  ss = sprintf('%2d:%2d:%f', C(4), C(5), C(6));
  title(ss);

  axis([-25, 25, -25, 25]);

  hold off;
  
  axis equal;
  grid on;
  
  pause(0.1);
end

drawnow;
