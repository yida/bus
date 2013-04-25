function txt = datafunction(~, event_obj, gps_data, imu_data)
    ps = get(event_obj, 'Position')
   
    format long;
    sprintf('%5.10f %5.10f', ps(1), ps(2));
    txt = {['x: ',num2str(ps(1))],...
        ['y: ',num2str(ps(2))]};
end
