clear all;
close all;

bus1 = bus(-3.5, -15, 0);

  OBJECT = {};
%  OBJECT{1} = struct('name','line', 'a', 0, 'b', 2.8, 'c', 1);
%  OBJECT{2} = struct('name','line', 'a', 1, 'b', 1, 'c', 0);
%  OBJECT{3} = struct('name','line', 'a', 2/3, 'b', 3, 'c', 1);
%  OBJECT{5} = struct('name', 'rectangle', 'cx', 0.5, 'cy', 2.6, 'theta', pi/3,'w', 0.4, 'h', 0.8);
  OBJECT{1} = struct('name', 'rectangle', 'cx', -4, 'cy', 7, 'theta', 0,'w', 1.766, 'h', 4.703);
  OBJECT{2} = struct('name', 'circle', 'cx', -10, 'cy', 8, 'r', 0.25);
  OBJECT{3} = struct('name', 'circle', 'cx', -11, 'cy', -7, 'r', 0.25);
  OBJECT{4} = struct('name', 'circle', 'cx', -11, 'cy', 7, 'r', 0.25);
  OBJECT{5} = struct('name', 'circle', 'cx', -12, 'cy', 8, 'r', 0.25);

%f1 = figure('menubar','none','Visible','off',...
f1 = figure('Visible','off',...
            'Position', [30,240, 1200,450]);
fontsize = 20;

timeStamp = 10;
dt = 1 / timeStamp;

time = 9
maxStamp = 100;
for t = 1 : time * timeStamp

  bus1 = busUpdate(bus1, dt);

%  subplot(4,4,[5,6,9,10]);
  subplot(1,2,1);

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
  plot_circle(OBJECT{4});
  plot_circle(OBJECT{5});
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

  lidar2 = lidar(bus1.theta - 3/2*pi, bus1.ver(2,:));
  lidar2 = intersectCal(lidar2, object);
  plot_lidar(lidar2);

  plot_intersection();

  C = clock();
  ss = sprintf('Simulation %2d:%2d:%f', C(4), C(5), C(6));
% title(ss, 'FontSize', fontsize);

  axis([-20, 10, -15, 15]);

  hold off;
  
  axis equal;
  grid on;

%  subplot(4,4,[1,2]);
%  plot(1:1081, lidar1.range, '.');
%  title('Left Lidar', 'FontSize', fontsize);
%  axis([1, 1081, 0, 30]);
%  grid on;

%  subplot(4,4,[3,4,7,8]);
  subplot(1,2,2);
  sectionInfo = lidarDetection(lidar1);
  nonzeroIdx = find(sectionInfo(:,1)~=0);
  sectionInfo = sectionInfo(nonzeroIdx', :);
  busStatic = bus(0, 0, 0); 
  busStatic.ver = plot_rectangle(busStatic);
  hold on;

  lidarCenter = busStatic.ver(1,:);
  busCorX = sectionInfo(:,4)' .* cos(lidar1.beamAngles(sectionInfo(:, 3)) - lidar1.pan) + lidarCenter(1);
  busCorY = sectionInfo(:,4)' .* sin(lidar1.beamAngles(sectionInfo(:, 3)) - lidar1.pan) + lidarCenter(2);

  plot(busCorX, busCorY,'r*');
%  hold off;
%  axis([-15 15 -15 15]);
%  grid on;

%  subplot(4,4,[13, 14]);
%  plot(1:1081, lidar2.range, '*');
%  title('Right Lidar', 'FontSize', fontsize);
%  axis([1, 1081, 0, 30]);
%  grid on;

%  subplot(4,4,[11,12,15,16]);
  sectionInfo = lidarDetection(lidar2);
  nonzeroIdx = find(sectionInfo(:,1)~=0);
  sectionInfo = sectionInfo(nonzeroIdx', :); 
  busStatic = bus(0, 0, 0); 
  busStatic.ver = plot_rectangle(busStatic);
  hold on;

  lidarCenter = busStatic.ver(2,:);
  busCorX = sectionInfo(:,4)' .* cos(lidar2.beamAngles(sectionInfo(:, 3)) - lidar2.pan - 3/2*pi) + lidarCenter(1);
  busCorY = sectionInfo(:,4)' .* sin(lidar2.beamAngles(sectionInfo(:, 3)) - lidar2.pan - 3/2*pi) + lidarCenter(2);

  plot(busCorX, busCorY,'r*');
%  hold off;
  axis([-15 15 -15 15]);
  grid on;

% movegui(f1,'center');
  set(f1, 'Visible', 'on');
  
  pause(0.1);
end

drawnow;
