function txt = dc_gps_imu_update(obj, event_obj, event_gps, event_imu,...
                                  gps_x, gps_y, gps_ts, gps_lat, gps_lon,...
                                  imu_ts, imu_value)
    ps = get(event_obj, 'Position');
    dataIdx = get(event_obj,'DataIndex');
    xdata = get(get(event_obj,'Target'),'XData');
    ydata = get(get(event_obj,'Target'),'YData');
    zdata = get(get(event_obj,'Target'),'ZData');

    cur_imu_pos = get(event_imu.DataCursor, 'Position');
    cur_gps_pos = get(event_gps.DataCursor, 'Position');

    if ps == cur_gps_pos(1:2)
%      fprintf(1, 'update gps\n');
      gps_idx = find( (gps_x(:) == ps(1)) & (gps_y(:) == ps(2)));
      g_ts = gps_ts(gps_idx);
      imu_front_ts = find(imu_ts>= g_ts);
      imu_back_ts = find(imu_ts <= g_ts);
      imu_front_ts(1);
      imu_back_ts(end);
      imu_position = [imu_ts(imu_front_ts(1)), imu_value(imu_front_ts(1)), 1];
      set(event_imu.CurrentDataCursor, 'Position', imu_position);
    elseif ps == cur_imu_pos(1:2)
%      fprintf(1, 'update imu\n');
      imu_idx = find( imu_ts(:) == ps(1) & imu_value(:) == ps(2));
      i_ts = imu_ts(imu_idx);
      gps_front_ts = find(gps_ts >= i_ts);
      gps_end_ts = find(gps_ts <= i_ts);
      gps_front_ts(1);
      gps_end_ts(end);
      gps_position = [gps_x(gps_front_ts(1)), gps_y(gps_front_ts(1)), 1];
      set(event_gps.CurrentDataCursor, 'Position', gps_position);
    else
      fprintf(1, 'update\n');
    end

    txt = {['x: ',num2str(ps(1))], ['y: ',num2str(ps(2))]};
%    data_idx = find( (gps_x(:) == ps(1)) & (gps_y(:) == ps(2)));
%    t = gps_ts(data_idx);
%    txt = {['x: ',num2str(ps(1))],...
%        ['y: ',num2str(ps(2))],...
%        ['time: ', sprintf('%10.6f', t(1))],...
%        ['lat: ', num2str(gps_lat(data_idx(1)))],...
%        ['lon: ', num2str(gps_lon(data_idx(1)))]};
end
