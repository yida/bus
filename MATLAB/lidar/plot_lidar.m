function plot_lidar(LIDAR)

%  numBeams = 1081;
%  beamRange = 3/2*pi;
%  MaxRange = 1;
%  lidarMaxRange = MaxRange * ones(1, numBeams);
%
%  lidarTheta = lidarTheta + beamRange; 
%
%  lidarAngles = beamRange/numBeams : beamRange/numBeams : beamRange;
%  lidarAngles = lidarAngles + lidarTheta;
%
%  lidarRange = lidarMaxRange;

  % lines : cy = ax + b
  % line 1 horizontal y = 2.8 ;
  a = 0; b = 2.8; c = 1;
  lidarRange1 = (a * LIDAR.center(1) + b - c * LIDAR.center(2))./...
                (c .* sin(LIDAR.beamAngles) - a .* cos(LIDAR.beamAngles));
  lidarRange1(lidarRange1 > LIDAR.maxRange) = LIDAR.maxRange;
  lidarRange1(lidarRange1 < 0) = LIDAR.maxRange;

  LIDAR.range = min(LIDAR.range, lidarRange1);

  % line 2 vertical x = -1
  c = 0; a = 1; b = 1;
  lidarRange1 = (a * LIDAR.center(1) + b - c * LIDAR.center(2))./...
                (c .* sin(LIDAR.beamAngles) - a .* cos(LIDAR.beamAngles));
  lidarRange1(lidarRange1 > LIDAR.maxRange) = LIDAR.maxRange;
  lidarRange1(lidarRange1 < 0) = LIDAR.maxRange;

  LIDAR.range = min(LIDAR.range, lidarRange1);


  % line 3 arbitary
  c = 1; a = 2 / 3; b = 3;
  lidarRange1 = (a * LIDAR.center(1) + b - c * LIDAR.center(2))./...
                (c .* sin(LIDAR.beamAngles) - a .* cos(LIDAR.beamAngles));
  lidarRange1(lidarRange1 > LIDAR.maxRange) = LIDAR.maxRange;
  lidarRange1(lidarRange1 < 0) = LIDAR.maxRange;

  LIDAR.range = min(LIDAR.range, lidarRange1);


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
  

% lidar = [lidarMaxRange .* cos(LIDAR.beamAngles); lidarMaxRange .* sin(LIDAR.beamAngles)];
  lidarRay = [LIDAR.range .* cos(LIDAR.beamAngles); LIDAR.range .* sin(LIDAR.beamAngles)];
% lidar = bsxfun(@plus, lidar, LIDAR.center');
  lidarRay = bsxfun(@plus, lidarRay, LIDAR.center');

  idx = 1:5:LIDAR.numBeams;

%  plot(lidar(1,idx), lidar(2,idx), 'w*');
%  plot(lidar1(1,idx), lidar1(2,idx), 'w*');

  for cnt = idx
%    plot([LIDAR.center(1,1), lidar(1,cnt)], [LIDAR.center(1,2), lidar(2,cnt)], 'r');
    plot([LIDAR.center(1,1), lidarRay(1,cnt)], [LIDAR.center(1,2), lidarRay(2,cnt)], 'r');
  end
  
  
