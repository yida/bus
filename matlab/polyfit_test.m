
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
%      [fitted_x, fitted_y, p] = imu_polyfit(centralized_ts, sample{sample_counter}.wy);
      subplot(2, sample_num_div, sample_counter);
      plot(centralized_ts, sample{sample_counter}.wy, '*');
%      hold on;
%      plot(fitted_x, fitted_y, 'r.');
%      hold off;
      grid on;
      sample_counter = sample_counter + 1;
    end
  end
end

fig = figure('Position', [scrz(3)/2 - width/2, scrz(4)/2 - height/2, width, height]);

sample_num_div = ceil(sample_num / 2);
sample_counter = 1;
for i = 1 : 2
  for j = 1 : sample_num_div
    if sample_counter <= sample_num
%      if sample{sample_counter}.label == 1
%        [start_span, end_span] = range2index(left_fitted_x, -span_left_ts/2, span_left_ts/2);
%        plot(left_fitted_x(start_span:end_span), left_fitted_y(start_span:end_span), 'r.');

      centralized_ts = centralize(sample{sample_counter}.ts, sample{sample_counter}.wy);
      Y_left = polyval(left_p, centralized_ts);
      Q_left = sum((sample{sample_counter}.wy - Y_left).^2);
      Y_right = polyval(right_p, centralized_ts);
      Q_right = sum((sample{sample_counter}.wy - Y_right).^2);
      subplot(2, sample_num_div, sample_counter);
      plot(centralized_ts, sample{sample_counter}.wy, '*');
      hold on;
      plot(centralized_ts, Y_left, 'r.');
      plot(centralized_ts, Y_right, 'r.');
      hold off;
      grid on;
      xlabel([num2str(Q_left), ',', num2str(Q_right)]);
      sample_counter = sample_counter + 1;
    end
  end
end

imu_start_idx = 1;
imu_end_idx = numel(imu_ts);
%[imu_start_idx, imu_end_idx] = range2index(imu_ts, 946684969.05, 946688106.02);

Q_right = ones(size(imu_wy)) * 20;
imu_ts_filter = imu_ts(imu_start_idx : imu_end_idx);
imu_sample_num = numel(imu_ts_filter);
imu_idx = 1;
offset_idx = 1;
while imu_idx < imu_sample_num & offset_idx < imu_sample_num
  offset_idx = imu_idx + 1;
  while (abs(imu_ts_filter(offset_idx) - imu_ts_filter(imu_idx)) < span_right_ts) & (offset_idx < imu_sample_num) 
    offset_idx = offset_idx + 1;
  end
%  fprintf(1, '%d %d %d\n', imu_idx, offset_idx, offset_idx - imu_idx);
  mid_idx = floor((imu_idx + offset_idx)/2);
  centralized_ts = zeros(1, offset_idx - imu_idx + 1);
  section_num = numel(centralized_ts);
  for i = 1 : section_num
    centralized_ts(i) = imu_ts_filter(mid_idx) - imu_ts_filter(imu_idx + i - 1);
  end
  Y_right = polyval(right_p, centralized_ts);
  size(Y_right);
  size(imu_wy(imu_idx:offset_idx));
  Q_right(imu_idx) = sum((imu_wy(imu_idx:offset_idx) - Y_right).^2);
  imu_idx = imu_idx + 1;
end


Q_left = ones(size(imu_wy)) * 20;
imu_ts_filter = imu_ts(imu_start_idx : imu_end_idx);
imu_sample_num = numel(imu_ts_filter);
imu_idx = 1;
offset_idx = 1;
while imu_idx < imu_sample_num & offset_idx < imu_sample_num
  offset_idx = imu_idx + 1;
  while (abs(imu_ts_filter(offset_idx) - imu_ts_filter(imu_idx)) < span_left_ts) & (offset_idx < imu_sample_num) 
    offset_idx = offset_idx + 1;
  end
%  fprintf(1, '%d %d %d\n', imu_idx, offset_idx, offset_idx - imu_idx);
  mid_idx = floor((imu_idx + offset_idx)/2);
  centralized_ts = zeros(1, offset_idx - imu_idx + 1);
  section_num = numel(centralized_ts);
  for i = 1 : section_num
    centralized_ts(i) = imu_ts_filter(mid_idx) - imu_ts_filter(imu_idx + i - 1);
  end
  Y_left = polyval(left_p, centralized_ts);
  size(Y_left);
  size(imu_wy(imu_idx:offset_idx));
  Q_left(imu_idx) = sum((imu_wy(imu_idx:offset_idx) - Y_left).^2);
  imu_idx = imu_idx + 1;
end

Q = bsxfun(@min, Q_left, Q_right);
%Q = Q_left;
%Q = Q_right;

% match gps with fitting quality
fprintf(1, 'imu stamp %10.6f %10.6f\n', imu_ts(imu_start_idx), imu_ts(imu_end_idx));
fprintf(1, 'gps stamp %10.6f %10.6f\n', gps_ts(gps_start_idx), gps_ts(gps_end_idx));

gps_Q_idx = binary_matching(imu_ts, gps_ts);
gps_Q_left = Q_left(gps_Q_idx);
gps_Q_right = Q_right(gps_Q_idx);

%% match scale
x_offset = 0;
y_offset = 0;
%scale = 1.77;  
%x_offset = 1325;
%y_offset = 1210;
%roadmap = imread([datapath, 'roadmap.jpeg']);
%img = imresize(roadmap, scale);
%
fig_gps = figure; 

%h_img = image(img);
%set(h_img, 'AlphaData', 0.5);

hold on;
gps_line = plot(gps_x(gps_start_idx:gps_end_idx) + x_offset, +gps_y(gps_start_idx:gps_end_idx) + y_offset,...
                      'LineWidth', 2, 'Color', [0.5, 0.5, 0.50]);
hold on;
for i = gps_start_idx : gps_end_idx
  if gps_Q_left(i) <= 3.5
    plot(gps_x(i) + x_offset, +gps_y(i) + y_offset, 'b*');
  elseif gps_Q_right(i) <= 3.5
    plot(gps_x(i) + x_offset, +gps_y(i) + y_offset, 'b^');
  end
end
%  gps_label_line = plot(gps_x(gps_label), gps_y(gps_label), 'r*');

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
plot(imu_ts_filter, Q(imu_start_idx:imu_end_idx), 'Color', [0.45 0.1, 0.33]);
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

