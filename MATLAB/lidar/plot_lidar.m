function plot_lidar(lidarTheta, lidarCenter)

  numBeams = 1081;
  beamRange = 3/2*pi;
  MaxRange = 1;
  lidarMaxRange = MaxRange * ones(1, numBeams);

  lidarTheta = lidarTheta + beamRange; 

  lidarAngles = beamRange/numBeams : beamRange/numBeams : beamRange;
  lidarAngles = lidarAngles + lidarTheta;

  lidarRange = lidarMaxRange;

  % lines : cy = ax + b
  % line 1 horizontal y = 2.8 ;
  a = 0; b = 2.8; c = 1;
  lidarRange1 = (a * lidarCenter(1) + b - c * lidarCenter(2))./...
                (c .* sin(lidarAngles) - a .* cos(lidarAngles));
  lidarRange1(lidarRange1 > MaxRange) = MaxRange;
  lidarRange1(lidarRange1 < 0) = MaxRange;

  lidarRange = min(lidarRange, lidarRange1);

  % line 2 vertical x = -1
  c = 0; a = 1; b = 1;
  lidarRange1 = (a * lidarCenter(1) + b - c * lidarCenter(2))./...
                (c .* sin(lidarAngles) - a .* cos(lidarAngles));
  lidarRange1(lidarRange1 > MaxRange) = MaxRange;
  lidarRange1(lidarRange1 < 0) = MaxRange;

  lidarRange = min(lidarRange, lidarRange1);


  % line 3 arbitary
  c = 1; a = 2 / 3; b = 3;
  lidarRange1 = (a * lidarCenter(1) + b - c * lidarCenter(2))./...
                (c .* sin(lidarAngles) - a .* cos(lidarAngles));
  lidarRange1(lidarRange1 > MaxRange) = MaxRange;
  lidarRange1(lidarRange1 < 0) = MaxRange;

  lidarRange = min(lidarRange, lidarRange1);


  % Circle 1
  cx = 0.5; cy = 2.1; r = 0.04;
  A = cos(lidarAngles).^2 + sin(lidarAngles).^2;
  C = (lidarCenter(1) - cx).^2 + (lidarCenter(2) - cy).^2 - r^2;
  sqrtroot = 4.*((lidarCenter(1)-cx).*cos(lidarAngles) + (lidarCenter(2)-cy).*sin(lidarAngles)).^2 -...
  4.*((lidarCenter(1)-cx).^2+(lidarCenter(2)-cy).^2 - r^2);
  B = 2.* ((lidarCenter(1)-cx).*cos(lidarAngles) + (lidarCenter(2)-cy).*sin(lidarAngles));
  Bsign = B ./ abs(B);
  nonsectRayIdx = find(sqrtroot < 0);
  sectRayIdx = find(sqrtroot >= 0);
  sqrtroot(nonsectRayIdx) = 100000;
  sqrtroot(sectRayIdx) = sqrt(sqrtroot(sectRayIdx));
  lidarRange2 = (-B -Bsign .* sqrtroot) / 2; 
  lidarRange2(lidarRange2 > MaxRange) = MaxRange;
  lidarRange2(lidarRange2 < 0) = MaxRange;

  lidarRange = min(lidarRange, lidarRange2);
  

% lidar = [lidarMaxRange .* cos(lidarAngles); lidarMaxRange .* sin(lidarAngles)];
  lidar = [lidarRange .* cos(lidarAngles); lidarRange .* sin(lidarAngles)];
% lidar = bsxfun(@plus, lidar, lidarCenter');
  lidar = bsxfun(@plus, lidar, lidarCenter');

  idx = 1:5:numBeams;

%  plot(lidar(1,idx), lidar(2,idx), 'w*');
%  plot(lidar1(1,idx), lidar1(2,idx), 'w*');

  for cnt = idx
%    plot([lidarCenter(1,1), lidar(1,cnt)], [lidarCenter(1,2), lidar(2,cnt)], 'r');
    plot([lidarCenter(1,1), lidar(1,cnt)], [lidarCenter(1,2), lidar(2,cnt)], 'r');
  end
  
  
