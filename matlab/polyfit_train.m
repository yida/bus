section_time = [0, Inf];

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

label_start_idx = 1;
label_end_idx = size(label_ts, 2);
[label_start_idx, label_end_idx] = range2index(label_ts, [section_time]);

gps_lat = cells2array(gps, 'latitude');
gps_lon = cells2array(gps, 'longtitude');
gps_ts  = cells2array(gps, 'timestamp');
gps_x = cells2array(gps, 'x');
gps_y = cells2array(gps, 'y');

gps_start_idx = 1;
gps_end_idx = size(gps_ts, 2);
[gps_start_idx, gps_end_idx] = range2index(gps_ts, section_time);

fprintf(1, 'GPS time : %10.6f %10.6f\n', gps_ts(gps_start_idx), gps_ts(gps_end_idx));
tic
gps_label = binary_matching(gps_ts, label_ts);
toc

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

kalman_filter;

imu_start_idx = 1;
imu_end_idx = size(imu_ts, 2);
[imu_start_idx, imu_end_idx] = range2index(imu_ts, section_time);

fprintf(1, 'binary matching label with imu\n');
tic
imu_label_idx = binary_matching(imu_ts, label_ts);
toc
[imu_label_idx, I, J] = unique(imu_label_idx);
imu_label_value = label_value(I);

last_label_idx = 1;
imu_label_mask = zeros(size(imu_ts));
imu_label_mask(imu_label_idx) = 1;

% label array for hmm training
imu_label = ones(size(imu_ts)) * 3;

%% process label array
separate_offset = 10;
idx_offset = 20;
imu_cells = {};
label_idx = 1;
for i = 2 : numel(imu_label_idx)
  if (imu_label_idx(i) - imu_label_idx(last_label_idx)) > separate_offset
    if mod(label_idx, 2) == 1
      fprintf(1, '%s %02d %05d %05d %f %f\n', 'separate', label_idx, imu_label_idx(last_label_idx), imu_label_idx(i),...
              imu_ts(imu_label_idx(last_label_idx)), imu_ts(imu_label_idx(i)));
      imu_label_mask(imu_label_idx(last_label_idx) - idx_offset : imu_label_idx(i) + idx_offset) = 1;
      if imu_label_value(last_label_idx) == 1;
        imu_label(imu_label_idx(last_label_idx) - idx_offset : imu_label_idx(i) + idx_offset) = 1;
      elseif imu_label_value(last_label_idx) == -1;
        imu_label(imu_label_idx(last_label_idx) - idx_offset : imu_label_idx(i) + idx_offset) = 2;
      end
      imu_cells{numel(imu_cells) + 1} = imu_cell(last_label_idx, i, idx_offset, imu_ts,...
                                              imu_r, imu_p, imu_y, imu_wr, imu_wp, imu_wy_filter,...
                                              imu_ax, imu_ay, imu_az, imu_label_idx);
      imu_cells{numel(imu_cells)}.label = imu_label_value(last_label_idx);
    end
    label_idx = label_idx + 1;
  end
  last_label_idx = i;
end

sample = imu_sample_merge({}, imu_cells);


scrz = get(0, 'screensize');
width = 1300;
height = 400;

sample_num = numel(sample);
fig = figure('Position', [scrz(3)/2 - width/2, scrz(4)/2 - height/2,...
                          width, height]);

sample_num_div = ceil(sample_num / 2);

sample_counter = 1;
for i = 1 : 2
  for j = 1 : sample_num_div
    if sample_counter <= sample_num
      centralized_ts = centralize(sample{sample_counter}.ts, sample{sample_counter}.wy);
      [fitted_x, fitted_y, p] = imu_polyfit(centralized_ts, sample{sample_counter}.wy);
      subplot(2, sample_num_div, sample_counter);
      plot(fitted_x, sample{sample_counter}.wy, '*');
      hold on;
      plot(fitted_x, fitted_y, 'r.');
      hold off;
      grid on;
      sample_counter = sample_counter + 1;
    end
  end
end

imu_left_ts = [];
imu_left_wy = [];
imu_right_ts = [];
imu_right_wy = [];

span_left_ts_array = [];
span_left_ts_counter = 1;
span_right_ts_array = [];
span_right_ts_counter = 1;

for i = 1 : sample_num - 1
  if sample{i}.label == 1
    span_ts = sample{i}.ts(end) - sample{i}.ts(1);
    span_left_ts_array(span_left_ts_counter) = span_ts;
    span_left_ts_counter = span_left_ts_counter + 1;

    centralized_ts = centralize(sample{i}.ts, sample{i}.wy);
    imu_left_ts = [imu_left_ts, centralized_ts];
    imu_left_wy = [imu_left_wy, sample{i}.wy];
  else
    span_ts = sample{i}.ts(end) - sample{i}.ts(1);
    span_right_ts_array(span_right_ts_counter) = span_ts;
    span_right_ts_counter = span_right_ts_counter + 1;

    centralized_ts = centralize(sample{i}.ts, sample{i}.wy);
    imu_right_ts = [imu_right_ts, centralized_ts];
    imu_right_wy = [imu_right_wy, sample{i}.wy];
  end
end

span_left_ts = mean(span_left_ts_array);
span_right_ts = mean(span_right_ts_array);

figure; plot(imu_left_ts, imu_left_wy, '.');
hold on;
[left_fitted_x, left_fitted_y, left_p] = imu_polyfit(imu_left_ts, imu_left_wy);
plot(left_fitted_x, left_fitted_y, 'r*');
hold off; 
grid;

figure; plot(imu_right_ts, imu_right_wy, '.');
hold on;
[right_fitted_x, right_fitted_y, right_p] = imu_polyfit(imu_right_ts, imu_right_wy);
plot(right_fitted_x, right_fitted_y, 'r*');
hold off; 
grid;

quadratic = {};
quadratic.left_p = left_p;
quadratic.right_p = right_p;
quadratic.span_left_ts = span_left_ts;
quadratic.span_right_ts = span_right_ts;
