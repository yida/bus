function range = lineIntersect(LIDAR, LINE)

  lidarRange = (LINE.a * LIDAR.center(1) + LINE.b - LINE.c * LIDAR.center(2))./...
               (LINE.c .* sin(LIDAR.beamAngles) - LINE.a .* cos(LIDAR.beamAngles));
  lidarRange(lidarRange > LIDAR.maxRange) = LIDAR.maxRange;
  lidarRange(lidarRange < 0) = LIDAR.maxRange;

  range = min(LIDAR.range, lidarRange);
