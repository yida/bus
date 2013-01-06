function plot_lidar(LIDAR)

 
  lidarRay = [LIDAR.range .* cos(LIDAR.beamAngles);...
              LIDAR.range .* sin(LIDAR.beamAngles)];
  lidarRay = bsxfun(@plus, lidarRay, LIDAR.center');

  idx = 1 : 5 : LIDAR.numBeams;

%  plot(lidarRay(1,idx), lidarRay(2,idx), 'w*');

  for cnt = idx
    plot([LIDAR.center(1,1), lidarRay(1,cnt)],...
          [LIDAR.center(1,2), lidarRay(2,cnt)], 'r');
  end
  
  
