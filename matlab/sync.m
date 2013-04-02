%size(gpspos)
%size(magdata)

for i = 1 : size(gpspos, 2)
%for i = 1 : 1
  gpst = gpspos(4, i);
  idxf = find(magdata(2, :) >= gpst);
  idxe = find(magdata(2, :) <= gpst);
  idxm = floor((idxf(1) + idxe(end))/2);
  gpspos(6, i) = magdata(1, idxm);

%   idxf = find(pos(4, :) >= gpst);
%   idxe = find(pos(4, :) <= gpst);
%   if numel(idxe) == 0 idxe = idxf; end;
%   idxm = floor((idxf(1) + idxe(end))/2);
%   gpspos(7, i) = pos(7, idxm);

end
