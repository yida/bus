function range = circleIntersect(LIDAR, CYCLE)

  cx = CYCLE.cx; cy = CYCLE.cy; r = CYCLE.r;
  A = cos(LIDAR.beamAngles).^2 + sin(LIDAR.beamAngles).^2;
  C = (LIDAR.center(1) - cx).^2 + (LIDAR.center(2) - cy).^2 - r^2;
  sqrtroot = 4.*((LIDAR.center(1)-cx).*cos(LIDAR.beamAngles) + (LIDAR.center(2)-cy).*sin(LIDAR.beamAngles)).^2 -...
  4.*((LIDAR.center(1)-cx).^2+(LIDAR.center(2)-cy).^2 - r^2);
  B = 2.* ((LIDAR.center(1)-cx).*cos(LIDAR.beamAngles) + (LIDAR.center(2)-cy).*sin(LIDAR.beamAngles));
  Bsign = B ./ abs(B);
  nonsectRayIdx = find(sqrtroot < 0);
  sectRayIdx = find(sqrtroot >= 0);
  sqrtroot(nonsectRayIdx) = 100000;
  sqrtroot(sectRayIdx) = sqrt(sqrtroot(sectRayIdx));
  lidarRange2 = min( (-B -Bsign .* sqrtroot) / 2, (-B +Bsign .* sqrtroot) / 2 ); 
  lidarRange2(lidarRange2 > LIDAR.maxRange) = LIDAR.maxRange;
  lidarRange2(lidarRange2 < 0) = LIDAR.maxRange;

  range = min(LIDAR.range, lidarRange2);
 
