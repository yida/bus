function LIDAR = lidar(PanAngle, Center)
  LIDAR.numBeams = 1081;
  LIDAR.beamRange = 3 / 2 * pi;
  LIDAR.maxRange = 30;
  LIDAR.range = LIDAR.maxRange * ones(1, LIDAR.numBeams); 
  LIDAR.theta = PanAngle + LIDAR.beamRange;
  LIDAR.center = Center;
  LIDAR.beamAngles = LIDAR.beamRange / LIDAR.numBeams :...
                    LIDAR.beamRange / LIDAR.numBeams : LIDAR.beamRange;
  LIDAR.beamAngles = LIDAR.beamAngles + LIDAR.theta;

