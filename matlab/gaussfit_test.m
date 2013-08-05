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
      subplot(2, sample_num_div, sample_counter);
      plot(centralized_ts, sample{sample_counter}.wy, '*');
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
      centralized_ts = centralize(sample{sample_counter}.ts, sample{sample_counter}.wy);
      Y_left = 1/(sqrt(2 * pi * gauss.sigma_left)) * gaussmf(centralized_ts, [gauss.sigma_left, gauss.mu_left]);
      Q_left = sum((sample{sample_counter}.wy - Y_left).^2);
      Y_right = -1/(sqrt(2 * pi * gauss.sigma_right)) * gaussmf(centralized_ts, [gauss.sigma_right, gauss.mu_right]);
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
  while (abs(imu_ts_filter(offset_idx) - imu_ts_filter(imu_idx)) < gauss.span_right_ts) & (offset_idx < imu_sample_num) 
    offset_idx = offset_idx + 1;
  end
%  fprintf(1, '%d %d %d\n', imu_idx, offset_idx, offset_idx - imu_idx);
  mid_idx = floor((imu_idx + offset_idx)/2);
  centralized_ts = zeros(1, offset_idx - imu_idx + 1);
  section_num = numel(centralized_ts);
  for i = 1 : section_num
    centralized_ts(i) = imu_ts_filter(mid_idx) - imu_ts_filter(imu_idx + i - 1);
  end
  Y_right = -1/(sqrt(2 * pi * gauss.sigma_right)) * gaussmf(centralized_ts, [gauss.sigma_right, gauss.mu_right]);
%  Y_right = polyval(right_p, centralized_ts);
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
  while (abs(imu_ts_filter(offset_idx) - imu_ts_filter(imu_idx)) < gauss.span_left_ts) & (offset_idx < imu_sample_num) 
    offset_idx = offset_idx + 1;
  end
%  fprintf(1, '%d %d %d\n', imu_idx, offset_idx, offset_idx - imu_idx);
  mid_idx = floor((imu_idx + offset_idx)/2);
  centralized_ts = zeros(1, offset_idx - imu_idx + 1);
  section_num = numel(centralized_ts);
  for i = 1 : section_num
    centralized_ts(i) = imu_ts_filter(mid_idx) - imu_ts_filter(imu_idx + i - 1);
  end
  Y_left = 1/(sqrt(2 * pi * gauss.sigma_left)) * gaussmf(centralized_ts, [gauss.sigma_left, gauss.mu_left]);
%  Y_left = polyval(left_p, centralized_ts);
  size(Y_left);
  size(imu_wy(imu_idx:offset_idx));
  Q_left(imu_idx) = sum((imu_wy(imu_idx:offset_idx) - Y_left).^2);
  imu_idx = imu_idx + 1;
end

Q = bsxfun(@min, Q_left, Q_right);
%Q = Q_left;
%Q = Q_right;

alpha_max_idx_filter = ones(size(Q)) * 3;
threshold = 2.5;
alpha_max_idx_filter(Q_left <= threshold) = 2;
alpha_max_idx_filter(Q_right <= threshold) = 1;

fig_alpha = figure;
plot(imu_ts(imu_start_idx:imu_end_idx), imu_wy_filter(imu_start_idx:imu_end_idx));
hold on;
plot(imu_ts(imu_start_idx:imu_end_idx), imu_label(imu_start_idx:imu_end_idx), 'r');
plot(imu_ts(imu_start_idx:imu_end_idx), alpha_max_idx_filter(imu_start_idx:imu_end_idx));
hold off;
grid on;

% Confusion Matrix and ROC curve
TPR_set = [];
FPR_set = [];
P_set = [];
R_set = [];

con_imu_ts = imu_ts;
con_imu_label = imu_label;
con_imu_predict = alpha_max_idx_filter;

con_imu_label(con_imu_label == 2) = 1;
con_imu_predict(con_imu_predict == 2) = 1;

%con_imu_mix = (con_imu_label == con_imu_predict);

% left and right
TP = sum(con_imu_label == 1 & con_imu_predict == 1);
FP = sum(con_imu_label == 3 & con_imu_predict == 1);
TN = sum(con_imu_label == 3 & con_imu_predict == 3);
FN = sum(con_imu_label == 1 & con_imu_predict == 3);

% left and right
TP = sum(con_imu_label == 1 & con_imu_predict == 1);
FP = sum(con_imu_label == 3 & con_imu_predict == 1);
TN = sum(con_imu_label == 3 & con_imu_predict == 3);
FN = sum(con_imu_label == 1 & con_imu_predict == 3);

% TPR
TPR_set = [TPR_set, true_positive_rate(TP, FP, FN, TN)];
% FPR
FPR_set = [FPR_set, false_positive_rate(TP, FP, FN, TN)];
% Precision 
P_set = [P_set, precision(TP, FP, FN, TN)];
% recall
R_set = [R_set, recall(TP, FP, FN, TN)];

roc_curve(TPR_set, FPR_set);
pr_curve(P_set, R_set);

unscented_kalman_filter;

roadmap = imread([datapath, 'roadmap.jpeg']);
img = imresize(roadmap, scale);

filter_idx = binary_matching(result(1, :), imu_ts);

gps_filter_x = result(5, filter_idx);
gps_filter_y = result(6, filter_idx);

gps_filter_qui_x = result(5, filter_idx(1:3000:end));
gps_filter_qui_x_off = result(5, filter_idx(1:3000:end) + 100);

gps_filter_qui_y = result(6, filter_idx(1:3000:end));
gps_filter_qui_y_off = result(6, filter_idx(1:3000:end) + 100);

gps_filter_qui_u = gps_filter_qui_x_off - gps_filter_qui_x;
gps_filter_qui_v = gps_filter_qui_y_off - gps_filter_qui_y;
gps_filter_qui_norm = sqrt(gps_filter_qui_u.^2 + gps_filter_qui_v.^2);
gps_filter_qui_u = gps_filter_qui_u ./ gps_filter_qui_norm;
gps_filter_qui_v = gps_filter_qui_v ./ gps_filter_qui_norm;

fig_gps = figure('Position', [0 fig_size(2) fig_width* 1.5 fig_height * 1.5]);
h_img = image(img);
hold on;
plot(gps_filter_x + x_offset, -gps_filter_y + y_offset, 'b.');
h_quiver = quiver(gps_filter_qui_x + x_offset, -gps_filter_qui_y + y_offset, gps_filter_qui_u, -gps_filter_qui_v, 0.25, 'LineWidth', 2, 'Color', 'r');
gps_filter_x_left = gps_filter_x(alpha_max_idx_filter == 1);
gps_filter_y_left = gps_filter_y(alpha_max_idx_filter == 1);
gps_filter_x_right = gps_filter_x(alpha_max_idx_filter == 2);
gps_filter_y_right = gps_filter_y(alpha_max_idx_filter == 2);

h_left_turn = plot(gps_filter_x_left + x_offset, -gps_filter_y_left + y_offset, '*k');
h_right_turn = plot(gps_filter_x_right + x_offset, -gps_filter_y_right + y_offset, '*m');

grid on;
legend('Bus Route', 'Direction', 'Detected Left Turn', 'Detected Right Turn');

%gps_ts = cells2array(gps, 'timestamp');
%gps_x = cells2array(gps, 'x');
%gps_y = cells2array(gps, 'y');
%
%gps_start_idx = 1;
%gps_end_idx = numel(gps_ts);
%
%
%% match gps with fitting quality
%fprintf(1, 'imu stamp %10.6f %10.6f\n', imu_ts(imu_start_idx), imu_ts(imu_end_idx));
%fprintf(1, 'gps stamp %10.6f %10.6f\n', gps_ts(gps_start_idx), gps_ts(gps_end_idx));
%
%gps_Q_idx = binary_matching(imu_ts, gps_ts);
%gps_Q_left = Q_left(gps_Q_idx);
%gps_Q_right = Q_right(gps_Q_idx);
%
%%% match scale
%x_offset = 0;
%y_offset = 0;
%%scale = 1.77;  
%%x_offset = 1325;
%%y_offset = 1210;
%%roadmap = imread([datapath, 'roadmap.jpeg']);
%%img = imresize(roadmap, scale);
%%
%fig_gps = figure; 
%
%%h_img = image(img);
%%set(h_img, 'AlphaData', 0.5);
%
%hold on;
%gps_line = plot(gps_x(gps_start_idx:gps_end_idx) + x_offset, +gps_y(gps_start_idx:gps_end_idx) + y_offset,...
%                      'LineWidth', 2, 'Color', [0.5, 0.5, 0.50]);
%hold on;
%for i = gps_start_idx : gps_end_idx
%  if gps_Q_left(i) <= 2.5
%    plot(gps_x(i) + x_offset, +gps_y(i) + y_offset, 'b*');
%  elseif gps_Q_right(i) <= 2.5
%    plot(gps_x(i) + x_offset, +gps_y(i) + y_offset, 'b^');
%  end
%end
%%  gps_label_line = plot(gps_x(gps_label), gps_y(gps_label), 'r*');
%
%hold off;
%grid on;
%axis equal;
%
%fig_imu = figure;
%%plot(imu_ts(imu_start_idx:imu_end_idx), imu_wr(imu_start_idx:imu_end_idx),...
%%      imu_ts(imu_start_idx:imu_end_idx), imu_wp(imu_start_idx:imu_end_idx),...
%imu_wy_line = plot(imu_ts(imu_start_idx:imu_end_idx), imu_wy(imu_start_idx:imu_end_idx));
%hold on;
%imu_label_line = plot(imu_ts(imu_start_idx:imu_end_idx),...
%                       imu_label_mask(imu_start_idx:imu_end_idx), 'r');
%plot(imu_ts_filter, Q(imu_start_idx:imu_end_idx), 'Color', [0.45 0.1, 0.33]);
%hold off;
%grid on;
%
%dcm_gps_obj = datacursormode(fig_gps);
%dcm_imu_obj = datacursormode(fig_imu);
%set(dcm_gps_obj, 'UpdateFcn', {@dc_gps_imu_update, dcm_gps_obj, dcm_imu_obj,...
%                                gps_x, gps_y, gps_ts, gps_lat, gps_lon, imu_ts, imu_wy});
%set(dcm_imu_obj, 'UpdateFcn', {@dc_gps_imu_update, dcm_gps_obj, dcm_imu_obj,...
%                                gps_x, gps_y, gps_ts, gps_lat, gps_lon, imu_ts, imu_wy});
%
%hTarget_wy = handle(imu_wy_line);
%hTarget_gps = handle(gps_line);
%
%hDatatip_wy = dcm_imu_obj.createDatatip(hTarget_wy);
%hDatatip_gps = dcm_gps_obj.createDatatip(hTarget_gps);
%
%
