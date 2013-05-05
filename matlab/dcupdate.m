function txt = dcupdate(obj, event_obj, event_imu, event_gps, gps, imu)
    ps = get(event_obj, 'Position');
    dataIdx = get(event_obj,'DataIndex');
    xdata = get(get(event_obj,'Target'),'XData');
    ydata = get(get(event_obj,'Target'),'YData');
    zdata = get(get(event_obj,'Target'),'ZData');

    cur_imu_pos = get(event_imu.DataCursor, 'Position');
    cur_gps_pos = get(event_gps.DataCursor, 'Position');

    if ps == cur_gps_pos(1:2)
      fprintf(1, 'update gps\n');
      gps_idx = find(gps(:, 1) == ps(1) & gps(:, 2) == ps(2));
      ts = gps(gps_idx, 4);
      imu_front_ts = find(imu(:, 7) >= ts);
      imu_back_ts = find(imu(:, 7) <= ts);
      imu_front_ts(1);
      imu_back_ts(end);
      imu_position = [imu(imu_front_ts(1), 7), imu(imu_front_ts(1), 6), 1];
      set(event_imu.CurrentDataCursor, 'Position', imu_position);
    elseif ps == cur_imu_pos(1:2)
      fprintf(1, 'update imu\n');
      imu_idx = find(imu(:, 7) == ps(1) & imu(:, 6) == ps(2));
      ts = imu(imu_idx, 7);
      gps_front_ts = find(gps(:, 4) >= ts);
      gps_end_ts = find(gps(:, 4) <= ts);
      gps_front_ts(1);
      gps_end_ts(end);
      gps_position = [gps(gps_front_ts(1), 1), gps(gps_front_ts(1), 2), 1];
      set(event_gps.CurrentDataCursor, 'Position', gps_position);
    else
      fprintf(1, 'update');
    end



    txt = {['x: ',num2str(ps(1))], ['y: ',num2str(ps(2))]};
end
