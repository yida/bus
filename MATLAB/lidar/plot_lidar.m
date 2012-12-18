function plot_lidar(lidarTheta, lidarCenter)

  numBeams = 1081;
  beamRange = 3/2*pi;
  MaxRange = 1;
  lidarMaxRange = MaxRange * ones(1, numBeams);

  lidarTheta = lidarTheta + beamRange; 

  lidarAngles = beamRange/numBeams : beamRange/numBeams : beamRange;
  lidarAngles = lidarAngles + lidarTheta;

  % line 1
  lidarRange = (2.8 - lidarCenter(2))./sin(lidarAngles);
  lidarRange(lidarRange > MaxRange) = MaxRange;
  lidarRange(lidarRange < 0) = MaxRange;

  % line 2
  lidarRange1 = (-1 - lidarCenter(1))./cos(lidarAngles);
  lidarRange1(lidarRange1 > MaxRange) = MaxRange;
  lidarRange1(lidarRange1 < 0) = MaxRange;

  lidarRange = min(lidarRange, lidarRange1);

  % Circle 1
%  sqrtroot = 4.*((lidarCenter(1)-0.5).*cos(lidarAngles) + (lidarCenter(2)-2.1).*sin(lidarAngles)).^2 -...
%  4.*((lidarCenter(1)-0.5).^2+(lidarCenter(2)-2.1).^2 + 0.02^2);
%  B = cos(lidarAngles) + sin(lidarAngles);
%  Bsign = B ./ abs(B);
%  nonsectRayIdx = find(sqrtroot < 0);
%  sectRayIdx = find(sqrtroot >= 0);
%  sqrtroot(nonsectRayIdx) = 0;
%  sqrtroot(sectRayIdx) = sqrt(sqrtroot(sectRayIdx));
%  sqrtroot
%  lidarRange2 = -B -Bsign .* sqrtroot / 2; 
%  lidarRange2(lidarRange2 > MaxRange) = MaxRange;
%  lidarRange2(lidarRange2 < 0) = MaxRange;

  

  lidar = [lidarMaxRange .* cos(lidarAngles); lidarMaxRange .* sin(lidarAngles)];
  lidar1 = [lidarRange .* cos(lidarAngles); lidarRange .* sin(lidarAngles)];
  lidar = bsxfun(@plus, lidar, lidarCenter');
  lidar1 = bsxfun(@plus, lidar1, lidarCenter');

  idx = 1:5:numBeams;

%  plot(lidar(1,idx), lidar(2,idx), 'w*');
  plot(lidar1(1,idx), lidar1(2,idx), 'w*');

  for cnt = idx
%    plot([lidarCenter(1,1), lidar(1,cnt)], [lidarCenter(1,2), lidar(2,cnt)], 'r');
    plot([lidarCenter(1,1), lidar1(1,cnt)], [lidarCenter(1,2), lidar1(2,cnt)], 'r');
  end
  
  
