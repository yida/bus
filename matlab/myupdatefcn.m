function txt = myupdatefcn(~, event_obj, pos, gpspos, imu)
    ps = get(event_obj, 'Position');
   
    datapoint = find( (gpspos(1, :) == ps(1)) & (gpspos(2, :) == ps(2)));
    t = gpspos(4, datapoint);
    if size(datapoint, 2) == 0
      datapoint = find( (pos(1, :) == ps(1)) & (pos(2,:) == ps(2)));
      t = pos(4, datapoint);
    end
    tf = t(1);
    te = t(end);
    idxf = find(imu(10, :) >= tf);
    idxe = find(imu(10, :) <= te);
    idf = idxf(1);
    ide = idxe(end);
    idm = floor((idf + ide)/2);
    %imu(1:6, min(idf, ide):max(ide, idf))';
    imu(1:6, idm)';
    txt = {['TimeStamp:',num2str(imu(10, idf))],...
        ['x: ',num2str(ps(1))], ['y: ',num2str(ps(2))],...
        ['gx: ',num2str(imu(4, idm))],...
        ['gy: ',num2str(imu(5, idm))],...
        ['gz: ',num2str(imu(6, idm))]};
end