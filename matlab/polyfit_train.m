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

