function plot_lidar(lidarTheta, lidarCenter)

  numBeams = 1081;
  beamRange = 3/2*pi;
  lidarMaxRange = 0.5;

  lidarTheta = lidarTheta + beamRange; 

  lidarAngles = beamRange/numBeams : beamRange/numBeams : beamRange;
  lidarAngles = lidarAngles + lidarTheta;
  lidar = [lidarMaxRange * cos(lidarAngles); lidarMaxRange * sin(lidarAngles)];
  lidar = bsxfun(@plus, lidar, lidarCenter');

  idx = 1:3:numBeams;

  plot(lidar(1,idx), lidar(2,idx), 'w*');

  for cnt = idx
    plot([lidarCenter(1,1), lidar(1,cnt)], [lidarCenter(1,2), lidar(2,cnt)], 'r');
  end
  
  
