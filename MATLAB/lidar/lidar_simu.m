clear all;
close all;

%busCenter = [0.5, 1.9];
busCenter = [0, 1.5];
busTheta = pi/2;
busTheta = pi/12*5;


for busTheta = 0 : pi/100 : pi/2 
%busTheta = 0;

  [axisRange, Ver] = plot_bus(busCenter, busTheta);
  hold on;

  % line 1
  plot([-3, 3], [2.8, 2.8]);
  % line 2
  plot([-1, -1], [0, 4]);
  % circle 1
  nseg = 60;
  theta = 0 : (2 * pi / nseg) : (2 * pi);
  cx = 0.5; cy = 2.1; r = 0.02;
  pline_x = r * cos(theta) + cx;
  pline_y = r * sin(theta) + cy;
  plot(pline_x, pline_y, 'k');
    
  axisGain = 3.3;
    
%  axis(axisRange.*[1/axisGain, axisGain, 1/axisGain, axisGain]);
  axis([-1.5, 1, 0, 4]);
  
  plot_lidar(busTheta, Ver(1,:));
  plot_lidar(busTheta - 3/2*pi, Ver(2,:));
  hold off;
  
  axis equal;
  grid on;
  
  pause(0.2);
end

drawnow;
