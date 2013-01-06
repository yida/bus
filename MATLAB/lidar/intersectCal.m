function LIDAR = intersectCal(LID)
  
  LIDAR = LID;

  OBJECT = {};
  OBJECT{1} = struct('name','line', 'a', 0, 'b', 2.8, 'c', 1);
  OBJECT{2} = struct('name','line', 'a', 1, 'b', 1, 'c', 0);
  OBJECT{3} = struct('name','line', 'a', 2/3, 'b', 3, 'c', 1);
  objectSize = size(OBJECT, 2);

  for i = 1 : objectSize
    if (strcmp(OBJECT{i}.name, 'line')) 
      LIDAR.range = lineIntersect(LIDAR, OBJECT{i});
    end
  end

  % Circle 1
  cx = 0.5; cy = 2.1; r = 0.04;
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
  lidarRange2 = (-B -Bsign .* sqrtroot) / 2; 
  lidarRange2(lidarRange2 > LIDAR.maxRange) = LIDAR.maxRange;
  lidarRange2(lidarRange2 < 0) = LIDAR.maxRange;

  LIDAR.range = min(LIDAR.range, lidarRange2);
  
