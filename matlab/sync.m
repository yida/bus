%size(gpspos)
%size(magdata)

for i = 1 : size(gpspos, 2)
%for i = 1 : 1
  gpst = gpspos(4, i);
  idxf = find(imu(10, :) >= gpst);
  idxe = find(imu(10, :) <= gpst);
  idxm = floor((idxf(1) + idxe(end))/2);
  gpspos(6, i) = imu(6, idxm);

%   idxf = find(pos(4, :) >= gpst);
%   idxe = find(pos(4, :) <= gpst);
%   if numel(idxe) == 0 idxe = idxf; end;
%   idxm = floor((idxf(1) + idxe(end))/2);
%   gpspos(7, i) = pos(7, idxm);

  idxf = find(imudata(10, :) >= gpst);
  idxe = find(imudata(10, :) <= gpst);
  if numel(idxf) == 0 
    idxf = idxe(end);
  end
  if numel(idxe) == 0
    idxe = idxf(1);
  end
  idxm = floor((idxf(1) + idxe(end))/2);
  gpspos(8, i) = imudata(9, idxm);
end
