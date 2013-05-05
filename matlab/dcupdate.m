function txt = dcupdate(obj, event_obj, event_imu, event_gps, gps, imu)
    ps = get(event_obj, 'Position');
    dataIdx = get(event_obj,'DataIndex');
    xdata = get(get(event_obj,'Target'),'XData');
    ydata = get(get(event_obj,'Target'),'YData');
    zdata = get(get(event_obj,'Target'),'ZData');

    cur_imu_pos = get(event_imu.DataCursor, 'Position');
    cur_gps_pos = get(event_gps.DataCursor, 'Position');
    sprintf('%.10f %.5f', cur_imu_pos(1), cur_imu_pos(2))
   
    txt = {['x: ',num2str(ps(1))], ['y: ',num2str(ps(2))]};
end
