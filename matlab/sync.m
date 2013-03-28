%size(gpspos)
%size(magdata)

for i = 1 : size(gpspos, 2)
%for i = 1 : 1
  gpst = gpspos(4, i);
  idxf = find(magdata(2, :) >= gpst);
  idxe = find(magdata(2, :) <= gpst);
%  idxe(1, end)
  idxm = floor((idxf(1) + idxe(end))/2)
  gpspos(5, i) = magdata(1, idxm);
end
