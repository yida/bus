function range = lineIntersect(LIDAR, LINE, p1, p2)

  lidarRange = (LINE.a * LIDAR.center(1) + LINE.b - LINE.c * LIDAR.center(2))./...
               (LINE.c .* sin(LIDAR.beamAngles) - LINE.a .* cos(LIDAR.beamAngles));
  if nargin > 2
    maxX = max(p1(1), p2(1));
    minX = min(p1(1), p2(1));
    maxY = max(p1(2), p2(2));
    minY = min(p1(2), p2(2));
    x = lidarRange .* cos(LIDAR.beamAngles) + LIDAR.center(1);
%    y = lidarRange .* sin(LIDAR.beamAngles) + LIDAR.center(2);
%    find((x >= minX & x < maxX) & (y >= minY & y < minY))
    validIdx = find(x < minX | x > maxX);
    lidarRange(validIdx) = LIDAR.maxRange;
  end
  lidarRange(lidarRange > LIDAR.maxRange) = LIDAR.maxRange;
  lidarRange(lidarRange < 0) = LIDAR.maxRange;


  range = min(LIDAR.range, lidarRange);
