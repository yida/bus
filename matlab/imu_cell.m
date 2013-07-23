function imu_struct = imu_cell(label_start, label_end, idx_offset,...
                              imu_ts, imu_r, imu_p, imu_y, imu_wr, imu_wp, imu_wy, imu_ax, imu_ay, imu_az, imu_label)
  imu_struct = [];
  imu_struct.ts = imu_ts(imu_label(label_start)  - idx_offset : imu_label(label_end) + idx_offset);
  imu_struct.r = imu_r(imu_label(label_start)  - idx_offset : imu_label(label_end) + idx_offset);
  imu_struct.p = imu_p(imu_label(label_start)  - idx_offset : imu_label(label_end) + idx_offset);
  imu_struct.y = imu_y(imu_label(label_start)  - idx_offset : imu_label(label_end) + idx_offset);
  
  imu_struct.wr = imu_wr(imu_label(label_start)  - idx_offset : imu_label(label_end) + idx_offset);
  imu_struct.wp = imu_wp(imu_label(label_start)  - idx_offset : imu_label(label_end) + idx_offset);
  imu_struct.wy = imu_wy(imu_label(label_start)  - idx_offset : imu_label(label_end) + idx_offset);
  
  imu_struct.ax = imu_ax(imu_label(label_start)  - idx_offset : imu_label(label_end) + idx_offset);
  imu_struct.ay = imu_ay(imu_label(label_start)  - idx_offset : imu_label(label_end) + idx_offset);
  imu_struct.az = imu_az(imu_label(label_start)  - idx_offset : imu_label(label_end) + idx_offset);
end
