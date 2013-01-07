function range = lineIntersect(LIDAR, LINE, p1, p2)

  Range = (LINE.a * LIDAR.center(1) + LINE.b - LINE.c * LIDAR.center(2))./...
               (LINE.c .* sin(LIDAR.beamAngles) - LINE.a .* cos(LIDAR.beamAngles));
  if nargin > 2
    maxX = max(p1(1), p2(1));
    minX = min(p1(1), p2(1));
    maxY = max(p1(2), p2(2));
    minY = min(p1(2), p2(2));
    test = [maxX, minX, maxY, minY];
    x = Range .* cos(LIDAR.beamAngles) + LIDAR.center(1);
    y = Range .* sin(LIDAR.beamAngles) + LIDAR.center(2);
    idxX = find(x > minX & x < maxX);
    idxY = find(y > minY & y < maxY);
    idx = unique([idxX, idxY]);

    lidarRange = LIDAR.rangeMax; 
    lidarRange(idx) = Range(idx);

  end
  lidarRange(lidarRange > LIDAR.maxRange) = LIDAR.maxRange;
  lidarRange(lidarRange < 0) = LIDAR.maxRange;


  range = min(LIDAR.range, lidarRange);
