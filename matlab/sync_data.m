function obs = sync_data(imu_ts, gps_ts)
  imu_ts;
  gps_ts;
  
  obs_counter = 1;
  imu_counter = 1;
  gps_counter = 1;
  obs = {};
  obs_sample_temp = {};
  obs_sample_temp.imu_idx = 0;
  obs_sample_temp.gps_idx = 0;
  
  while imu_counter <= numel(imu_ts) & gps_counter <= numel(gps_ts)
    obs_sample = obs_sample_temp;
    if imu_ts(imu_counter) < gps_ts(gps_counter) 
      obs_sample.ts = imu_ts(imu_counter);
      obs_sample.imu_idx = imu_counter;
      imu_counter = imu_counter + 1;
      obs{obs_counter} = obs_sample;
      obs_counter = obs_counter + 1; 
    else
      obs_sample.ts = gps_ts(gps_counter);
      obs_sample.gps_idx = gps_counter;
      gps_counter = gps_counter + 1;
      obs{obs_counter} = obs_sample;
      obs_counter = obs_counter + 1; 
    end
  end
  
  while imu_counter <= numel(imu_ts)
    obs_sample = obs_sample_temp;
    obs_sample.ts = imu_ts(imu_counter);
    obs_sample.imu_idx = imu_counter;
    imu_counter = imu_counter + 1;
    obs{obs_counter} = obs_sample;
    obs_counter = obs_counter + 1; 
  end
  
  while gps_counter <= numel(gps_ts)
    obs_sample = obs_sample_temp;
    obs_sample.ts = gps_ts(gps_counter);
    obs_sample.gps_idx = gps_counter;
    gps_counter = gps_counter + 1;
    obs{obs_counter} = obs_sample;
    obs_counter = obs_counter + 1; 
  end
end
