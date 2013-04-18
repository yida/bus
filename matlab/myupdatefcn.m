function txt = myupdatefcn(~, event_obj, pos, gpspos, imu)
    ps = get(event_obj, 'Position');
   
    datapoint = find( (gpspos(1, :) == ps(1)) & (gpspos(2, :) == ps(2)));
    t = gpspos(4, datapoint);
    if size(datapoint, 2) == 0
      datapoint = find( (pos(1, :) == ps(1)) & (pos(2,:) == ps(2)));
      t = pos(4, datapoint);
    end
    t1 = find(imu(4,:)>=t);
    t2 = find(imu(4,:)<=t);
    tidx = floor((t1(1) + t2(end)) / 2)
    yaw = pos(7, tidx) * 180 / pi;
    txt = {['x: ',num2str(ps(1))],...
        ['y: ',num2str(ps(2))],...
        ['yaw: ', num2str(imu(6,tidx))]};
end
