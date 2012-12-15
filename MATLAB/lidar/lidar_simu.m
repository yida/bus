clear all;
close all;

busCenter = [0.5, 1.9];
busTheta = pi/2;
busTheta = pi/12*5;

for busTheta = 0 : pi/100 : pi/2 
%busTheta = 0;

  [axisRange, Ver] = plot_bus(busCenter, busTheta);
  hold on;
  
  axisGain = 1.3;
    
  axis(axisRange.*[1/axisGain, axisGain, 1/axisGain, axisGain]);
  
  plot_lidar(busTheta, Ver(1,:));
  plot_lidar(busTheta - 3/2*pi, Ver(2,:));
  hold off;
  
  axis equal;
  grid on;
  
  pause(0.2);
end

drawnow;
