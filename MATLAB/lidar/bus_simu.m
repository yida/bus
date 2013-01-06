clear all;
close all;

%busCenter = [0.5, 1.9];
busCenter = [0, 1.5];

  OBJECT = {};
  OBJECT{1} = struct('name','line', 'a', 0, 'b', 2.8, 'c', 1);
  OBJECT{2} = struct('name','line', 'a', 1, 'b', 1, 'c', 0);
  OBJECT{3} = struct('name','line', 'a', 2/3, 'b', 3, 'c', 1);
  OBJECT{4} = struct('name', 'circle', 'cx', 0.5, 'cy', 2.1, 'r', 0.06);
  OBJECT{5} = struct('name', 'rectangle', 'cx', 0.5, 'cy', 2.6, 'theta', pi/3,'w', 0.4, 'h', 0.8);
  OBJECT{6} = struct('name', 'rectangle', 'cx', -1.2, 'cy', 1.5, 'theta', pi/3,'w', 0.4, 'h', 0.8);



for busTheta = 0 : pi/100 : pi/2 
%busTheta = 0;

  [axisRange, Ver] = plot_bus(busCenter, busTheta);
  hold on;

  % line 3
  plot([0, -1.5], [3, 2]);
  % line 1
  plot([-3, 3], [2.8, 2.8]);
  % line 2
  plot([-1, -1], [0, 4]);
  % circle 1
  plot_circle(OBJECT{4});
  % rectangle
  plot_rectangle(OBJECT{5});
  plot_rectangle(OBJECT{6});
   
  axisGain = 3.3;
    
%  axis(axisRange.*[1/axisGain, axisGain, 1/axisGain, axisGain]);
  axis([-1.5, 1, 0, 4]);
  
  object = OBJECT;
  lidar1 = lidar(busTheta, Ver(1,:));
  lidar1 = intersectCal(lidar1, object);
  plot_lidar(lidar1);
%  lidar2 = lidar(busTheta - 3/2*pi, Ver(2,:));
%  plot_lidar(lidar2);
  hold off;
  
  axis equal;
  grid on;
  
  pause(0.2);
end

drawnow;
