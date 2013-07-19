
label_ts = cells2array(label, 'timstamp');
label_value_str = cells2array(label, 'value');
label_value = zeros(size(label_value_str, 1));
for i = 1 : size(label_value_str, 2)
  if strcmp(label_value_str{i}, '0001') > 0 |...
      strcmp(label_value_str{i}, '0010') > 0 |...
      strcmp(label_value_str{i}, '01') > 0
    label_value(i) = -1;
  elseif strcmp(label_value_str{i}, '10') > 0 |...
      strcmp(label_value_str{i}, '1000') > 0 |...
      strcmp(label_value_str{i}, '0100') > 0
    label_value(i) = 1;
  end
end

gps_lat = cells2array(gps, 'latitude');
gps_lon = cells2array(gps, 'longtitude');
gps_ts  = cells2array(gps, 'timestamp');
gps_x = cells2array(gps, 'x');
gps_y = cells2array(gps, 'y');

gps_ts_start = gps_ts(1);
gps_ts_end = gps_ts(size(gps_ts, 2));
label_ts_start = label_ts(1);
label_ts_end = label_ts(size(label_ts, 2));

fprintf(1, 'GPS time : %10.6f %10.6f\n', gps_ts_start, gps_ts_end);
fprintf(1, 'label time : %10.6f %10.6f\n', label_ts_start, label_ts_end);

gps_start_idx = 1;
gps_end_idx = size(gps_ts, 2);
%[gps_start_idx, gps_end_idx] = range2index(gps_ts, 946684970.550000, 946685185.550000);
%[gps_start_idx, gps_end_idx] = range2index(gps_ts, 946687123.115478, 946687349.114410);
%[gps_start_idx, gps_end_idx] = range2index(gps_ts, 946687935.332183, 946689658.536865);
%[gps_start_idx, gps_end_idx] = range2index(gps_ts, 946686071.97, 946688069.350000);
%[gps_start_idx, gps_end_idx] = range2index(gps_ts, 946687123.115478, 946687349.114410);
%[gps_start_idx, gps_end_idx] = range2index(gps_ts, 946687935.332183, 946689658.536865);

% binary search
tic;
gps_label = zeros(size(label_ts));
for i = 1 : size(label_ts, 2)
  ts = label_ts(i);
  start_idx = gps_start_idx;
  end_idx = gps_end_idx;
  mid_idx = floor((start_idx + end_idx) / 2);
  while abs(gps_ts(mid_idx) - ts) > 0.000001 & (end_idx - start_idx) > 1
    if ts > gps_ts(mid_idx) 
      start_idx = mid_idx;
    else
      end_idx = mid_idx;
    end
    mid_idx = floor((start_idx + end_idx) / 2);
  end
  gps_label(i) = mid_idx;
end
toc;

%imu_ax = cells2array(imu, 'ax');
%imu_ay = cells2array(imu, 'ay');
%imu_az = cells2array(imu, 'az');
%imu_r = cells2array(imu, 'r');
%imu_p = cells2array(imu, 'p');
%imu_y = cells2array(imu, 'y');
%imu_wr = cells2array(imu, 'wr');
%imu_wp = cells2array(imu, 'wp');
%imu_wy = cells2array(imu, 'wy');
%imu_ts = cells2array(imu, 'timestamp');

%fig_imu = figure;
%hold on;
%plot(imu_ts, imu_ax);
%plot(imu_ts, imu_ay);
%plot(imu_ts, imu_az);
%hold off;
%grid on;

fig_gps = figure; 
plot(gps_x(gps_start_idx:gps_end_idx), gps_y(gps_start_idx:gps_end_idx), '.');
hold on;
plot(gps_x(gps_label), gps_y(gps_label), 'r*');
hold off;

grid on;
axis equal;

dcm_obj = datacursormode(fig_gps);
set(dcm_obj, 'UpdateFcn', {@gps_dc_update, gps_x, gps_y, gps_ts, gps_lat, gps_lon});

