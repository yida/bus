section_time = [0, Inf];
%section_time = [946684970.550000, 946685185.550000];
%section_time = [946687123.115478, 946687349.114410];
%section_time = [946687935.332183, 946689658.536865];
%section_time = [946686071.97, 946688069.350000];
%section_time = [946687140.115478, 946687349.114410];
%section_time = [946687935.332183, 946689658.536865];
%section_time = [946685157.5703, 946685549.9723];
%section_time = [946685875.6149, 946686779.085];
%section_time = [946684970.550000, 946685185.550000];
%section_time = [946686071.97, 946688069.350000];
%section_time = [946687150.115478, 946687349.114410];
%section_time = [946687935.332183, 946689658.536865];
%section_time = [946686071.97, 946688069.350000];

if exist('label', 'var') > 0 
  label_ts = cells2array(label, 'timestamp');
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
end

gps_lat = cells2array(gps, 'latitude');
gps_lon = cells2array(gps, 'longtitude');
gps_ts  = cells2array(gps, 'timestamp');
gps_x = cells2array(gps, 'x');
gps_y = cells2array(gps, 'y');

gps_ts_start = gps_ts(1);
gps_ts_end = gps_ts(size(gps_ts, 2));
fprintf(1, 'GPS time : %10.6f %10.6f\n', gps_ts_start, gps_ts_end);

gps_start_idx = 1;
gps_end_idx = size(gps_ts, 2);

[gps_start_idx, gps_end_idx] = range2index(gps_ts, section_time);

[label_start_idx, label_end_idx] = range2index(label_ts, [section_time]);
if exist('label', 'var') > 0
  label_ts_start = label_ts(1);
  label_ts_end = label_ts(size(label_ts, 2));
  fprintf(1, 'label time : %10.6f %10.6f\n', label_ts_start, label_ts_end);
end

% binary search
fprintf(1, 'binary matching label with gps');

if exist('label', 'var') > 0
  gps_label = binary_matching(gps_ts, label_ts(label_start_idx : label_end_idx));
end

imu_ax = cells2array(imu, 'ax');
imu_ay = cells2array(imu, 'ay');
imu_az = cells2array(imu, 'az');
imu_r = cells2array(imu, 'r');
imu_p = cells2array(imu, 'p');
imu_y = cells2array(imu, 'y');
imu_wr = cells2array(imu, 'wr');
imu_wp = cells2array(imu, 'wp');
imu_wy = cells2array(imu, 'wy');
imu_ts = cells2array(imu, 'timestamp');

imu_start_idx = 1;
imu_end_idx = size(imu_ts, 2);
[imu_start_idx, imu_end_idx] = range2index(imu_ts, section_time);

fprintf(1, 'binary matching label with imu');

if exist('label', 'var') > 0
  imu_label = binary_matching(imu_ts, label_ts(label_start_idx : label_end_idx));
end

imu_label = unique(imu_label);

idx_offset = 40;
imu_cells = {};
imu_cells_counter = 1; 
%
imu_label_mask = zeros(size(imu_ts));
imu_label_mask(imu_label) = 1;
%
%for i = 1 : 2 : numel(imu_label)
%  imu_label_mask(imu_label(i)  - idx_offset : imu_label(i + 1) + idx_offset) = 1;
%  imu_cells{imu_cells_counter} = imu_cell(i, i + 1, idx_offset, imu_ts, imu_r, imu_p, imu_y, imu_wr, imu_wp, imu_wy, imu_ax, imu_ay, imu_az, imu_label);
%  imu_cells_counter = imu_cells_counter + 1;
%end
%
%
%imu_wy = imu_wy .* imu_label_mask;

fig_gps = figure; 
gps_line = plot(gps_x(gps_start_idx:gps_end_idx), gps_y(gps_start_idx:gps_end_idx), '.');
hold on;
if exist('label', 'var') > 0
  gps_label_line = plot(gps_x(gps_label), gps_y(gps_label), 'r*');
end
hold off;

grid on;
axis equal;

fig_imu = figure;
%plot(imu_ts(imu_start_idx:imu_end_idx), imu_wr(imu_start_idx:imu_end_idx),...
%      imu_ts(imu_start_idx:imu_end_idx), imu_wp(imu_start_idx:imu_end_idx),...
imu_wy_line = plot(imu_ts(imu_start_idx:imu_end_idx), imu_wy(imu_start_idx:imu_end_idx));
hold on;
imu_label_line = plot(imu_ts(imu_start_idx:imu_end_idx),...
                       imu_label_mask(imu_start_idx:imu_end_idx), 'r');
hold off;
grid on;

dcm_gps_obj = datacursormode(fig_gps);
dcm_imu_obj = datacursormode(fig_imu);
set(dcm_gps_obj, 'UpdateFcn', {@dc_gps_imu_update, dcm_gps_obj, dcm_imu_obj,...
                                gps_x, gps_y, gps_ts, gps_lat, gps_lon, imu_ts, imu_wy});
set(dcm_imu_obj, 'UpdateFcn', {@dc_gps_imu_update, dcm_gps_obj, dcm_imu_obj,...
                                gps_x, gps_y, gps_ts, gps_lat, gps_lon, imu_ts, imu_wy});

hTarget_wy = handle(imu_wy_line);
hTarget_gps = handle(gps_line);

hDatatip_wy = dcm_imu_obj.createDatatip(hTarget_wy);
hDatatip_gps = dcm_gps_obj.createDatatip(hTarget_gps);

