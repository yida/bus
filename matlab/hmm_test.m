section_time = [0, Inf];
%section_time = [946684970.550000, 946685185.550000];
%section_time = [946687123.115478, 946687349.114410];
%section_time = [946687935.332183, 946689658.536865];
%section_time = [946686071.97, 946688069.350000];
%section_time = [946687176.115478, 946689658.536865];
%section_time = [946687935.332183, 946689658.536865];
%section_time = [946685157.5703, 946685549.9723];
%section_time = [946685875.6149, 946686779.085];
%section_time = [946684970.550000, 946685185.550000];
%section_time = [946684969.05, 946688069.350000];

label_ts = cells2array(label, 'timestamp');
label_value_str = cells2array(label, 'value');
label_value = zeros(size(label_value_str, 1));
for i = 1 : size(label_value_str, 2)
  if strcmp(label_value_str{i}, '0001') > 0
    label_value(i) = -2;
  elseif strcmp(label_value_str{i}, '0010') > 0
    label_value(i) = -1;
  elseif strcmp(label_value_str{i}, '1000') > 0
    label_value(i) = 1;
  elseif strcmp(label_value_str{i}, '0100') > 0
    label_value(i) = 2;
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
imu_label = ones(size(imu_ts)) * 4;

%% process label array
separate_offset = 10;
idx_offset = 60;
label_idx = 1;
in_middle = 0;
in_middle_idx = 0;
for i = 2 : numel(imu_label_idx)
  if (imu_label_idx(i) - imu_label_idx(last_label_idx)) > separate_offset
      fprintf(1, '%s %02d %05d %05d %f %f %d\n', 'separate',...
               label_idx, imu_label_idx(last_label_idx), imu_label_idx(i),...
               imu_ts(imu_label_idx(last_label_idx)), imu_ts(imu_label_idx(i)),...
               imu_label_value(last_label_idx));

%      imu_label_mask(imu_label_idx(last_label_idx) - idx_offset : imu_label_idx(i) + idx_offset) = 1;
      if imu_label_value(last_label_idx) == 1
        in_middle = 1;
        in_middle_idx = last_label_idx;
%        imu_label(imu_label_idx(last_label_idx) - idx_offset : imu_label_idx(last_label_idx) + idx_offset) = 1;
      elseif imu_label_value(last_label_idx) == 2
        offset = floor((imu_label_idx(last_label_idx) - imu_label_idx(in_middle_idx)) / 3);
        imu_label(imu_label_idx(in_middle_idx) + offset : imu_label_idx(last_label_idx) - offset) = 2;
        in_middle = 2;
        imu_label(imu_label_idx(in_middle_idx) - offset : imu_label_idx(in_middle_idx) + offset) = 1;
        imu_label(imu_label_idx(last_label_idx) - offset : imu_label_idx(last_label_idx) + offset) = 3;
      elseif imu_label_value(last_label_idx) == -1
        in_middle = 1;
        in_middle_idx = last_label_idx;
%        imu_label(imu_label_idx(last_label_idx) - idx_offset : imu_label_idx(last_label_idx) + idx_offset) = 5;
      elseif imu_label_value(last_label_idx) == -2
        offset = floor((imu_label_idx(last_label_idx) - imu_label_idx(in_middle_idx)) / 3);
        imu_label(imu_label_idx(in_middle_idx) + offset : imu_label_idx(last_label_idx) - offset) = 6;
        in_middle = 2;
        imu_label(imu_label_idx(in_middle_idx) - offset : imu_label_idx(in_middle_idx) + offset) = 5;
        imu_label(imu_label_idx(last_label_idx) - offset : imu_label_idx(last_label_idx) + offset) = 7;
      end
    label_idx = label_idx + 1;
  end
  last_label_idx = i;
end

% generate prelabel
imu_prelabel = ones(size(imu_ts)) * -1;
for i = 2 : numel(imu_prelabel)
  imu_prelabel(i) = imu_label(i - 1);
end

fig_gps = figure; 
gps_line = plot(gps_x(gps_start_idx:gps_end_idx), gps_y(gps_start_idx:gps_end_idx), '.');
hold on;
gps_label_line = plot(gps_x(gps_label), gps_y(gps_label), 'r*');
hold off;
grid on;
axis equal;

fig_imu = figure;
imu_wy_filter_line = plot(imu_ts(imu_start_idx:imu_end_idx), imu_wy_filter(imu_start_idx:imu_end_idx));
hold on;
imu_wy_acc_filter_line = plot(imu_ts(imu_start_idx:imu_end_idx), imu_wy_acc_filter(imu_start_idx:imu_end_idx) + 0.5, 'k');
imu_label_line = plot(imu_ts(imu_start_idx:imu_end_idx), imu_label(imu_start_idx:imu_end_idx) * .25 - 1, 'r');
hold off;
grid on;

dcm_gps_obj = datacursormode(fig_gps);
%dcm_gps_label_obj = datacursormode(fig_gps);
dcm_imu_obj = datacursormode(fig_imu);
set(dcm_gps_obj, 'UpdateFcn', {@dc_gps_imu_update, dcm_gps_obj, dcm_imu_obj,...
                                gps_x, gps_y, gps_ts, gps_lat, gps_lon, imu_ts, imu_wy_filter});
set(dcm_imu_obj, 'UpdateFcn', {@dc_gps_imu_update, dcm_gps_obj, dcm_imu_obj,...
                                gps_x, gps_y, gps_ts, gps_lat, gps_lon, imu_ts, imu_wy_filter});

hTarget_wy = handle(imu_wy_filter_line);
hTarget_gps = handle(gps_line);
%hTarget_gps_label = handle(gps_label_line);

hDatatip_wy = dcm_imu_obj.createDatatip(hTarget_wy);
hDatatip_gps = dcm_gps_obj.createDatatip(hTarget_gps);
%hDatatip_gps_label = dcm_gps_label_obj.createDatatip(hTarget_gps_label);

state_set = {'left_start', 'left_in', 'left_end', 'unchanged', 'right_start', 'right_in', 'right_end'};

%hmm
%hmm.init_prob
%hmm.transit_prob
%hmm.obs_prob_mu
%hmm.obs_prob_sigma

% incomplete viberti
%psi = zeros(size(state_set));
%%for i = imu_start_idx : imu_end_idx
%for i = imu_start_idx : imu_start_idx + 1
%  obs_prob = zeros(size(state_set));
%  delta = zeros(size(state_set));
%
%  for s = 1 : numel(state_set)
%    obs_prob(s) = -1/(sqrt(2 * pi * hmm.obs_prob_sigma(s))) *...
%         gaussmf(imu_wy_filter(i), [hmm.obs_prob_sigma(s), hmm.obs_prob_mu(s)]);
%    if i == imu_start_idx 
%      delta(s) = hmm.init_prob(s) * obs_prob(s);
%    else
%      new_delta = zeros(size(state_set));
%      for ps = 1 : numel(state_set)
%        new_delta(ps) = delta(s) * hmm.transit_prob(ps, s);
%      end
%      [max_delta, max_idx] = max(new_delta);
%      delta(s) = max_delta * obs_prob(s);
%      psi(s) = max_idx;
%    end 
%  end
%  delta 
%end

% Forward
obs_prob = zeros(size(state_set));
alpha = zeros(size(state_set));
alpha_set = zeros(numel(imu_ts), numel(state_set));
for i = imu_start_idx : imu_end_idx
%for i = imu_start_idx : imu_start_idx + 2
  for s = 1 : numel(state_set)
    x = [imu_wy_filter(i); imu_wy_acc_filter(i)];
    SIGMA = hmm.obs_prob_sigma(:,:,s);
    diff = x - hmm.obs_prob_mu(:, s);
    obs_prob(s) = (2*pi)^(-1) * (det(SIGMA))^(-1/2) * exp(-0.5 * diff' * inv(SIGMA) * diff);
  end
  obs_prob = obs_prob ./ sum(obs_prob);
  for s = 1 : numel(state_set)
    if i == imu_start_idx
      alpha(s) = hmm.init_prob(s) * obs_prob(s);
    else
      trans_prob = 0;
      for ps = 1 : numel(state_set)
        trans_prob = trans_prob + alpha(ps) * hmm.transit_prob(ps, s);
      end
      alpha(s) = trans_prob * obs_prob(s);
    end
  end
  alpha = alpha./sum(alpha);
  alpha_set(i, :) = alpha;
end

[alpha_max, alpha_max_idx] = max(alpha_set, [], 2);

alpha_max_idx_filter = ones(size(alpha_max_idx));

start_turn = 0;
current_state = -1;
current_states = 0;
start_turn_idx = 1;

last_state = alpha_max_idx(1);
for i = 2 : numel(alpha_max_idx)
  if alpha_max_idx(i) ~= last_state
%    fprintf(1, 'state change : prev %d curr %d\n', last_state, alpha_max_idx(i));
    if alpha_max_idx(i) == 1 | alpha_max_idx(i) == 5
      if start_turn == 1
        if current_states == 3
          fprintf(1, 'end turning with full turning %d %d\n', last_state, alpha_max_idx(i));
          if last_state > 4
            alpha_max_idx_filter(start_turn_idx : i - 1) = 2;
          else
            alpha_max_idx_filter(start_turn_idx : i - 1) = 1.5;
          end
        else
%          fprintf(1, 'end turning with not full turning %d %d %d %d\n', last_state, alpha_max_idx(i), start_turn_idx, i);
        end
        start_turn = 0;
        current_states = 0;
      end
%      fprintf(1, 'start turning %d\n', alpha_max_idx(i));
      start_turn_idx = i;
      start_turn = 1;
      current_states = 1;
    elseif alpha_max_idx(i) == last_state + 1
%      fprintf(1, 'start turning increase %d %d\n', last_state, alpha_max_idx(i));
      current_states = current_states + 1;
    else
      if current_states == 3
        fprintf(1, 'end turning with full turning %d %d\n', last_state, alpha_max_idx(i));
        if last_state > 4
          alpha_max_idx_filter(start_turn_idx : i - 1) = 2;
        else
          alpha_max_idx_filter(start_turn_idx : i - 1) = 1.5;
        end
      else
%        fprintf(1, 'end turning with not full turning %d %d %d %d\n', last_state, alpha_max_idx(i), start_turn_idx, i);
      end
      start_turn = 0;
      current_states = 0;
    end
  end 
  last_state = alpha_max_idx(i);
end

% since turning separated, merge or filter the result

fig_alpha = figure;
plot(imu_ts(imu_start_idx:imu_end_idx), imu_wy_filter(imu_start_idx:imu_end_idx));
hold on;
plot(imu_ts(imu_start_idx:imu_end_idx), imu_label(imu_start_idx:imu_end_idx) *.10, 'r');
plot(imu_ts(imu_start_idx:imu_end_idx), 0.2 * alpha_max_idx_filter(imu_start_idx:imu_end_idx));
hold off;
grid on;

unscented_kalman_filter;
% match scale
scale = 1.80;  
x_offset = 1910;
y_offset = 790;

roadmap = imread([datapath, 'roadmap.jpeg']);
img = imresize(roadmap, scale);

%gps_label = binary_matching(gps_ts, label_ts);
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
gps_filter_x_left = gps_filter_x(alpha_max_idx_filter == 1.5);
gps_filter_y_left = gps_filter_y(alpha_max_idx_filter == 1.5);
gps_filter_x_right = gps_filter_x(alpha_max_idx_filter == 2);
gps_filter_y_right = gps_filter_y(alpha_max_idx_filter == 2);

h_left_turn = plot(gps_filter_x_left + x_offset, -gps_filter_y_left + y_offset, '*k');
h_right_turn = plot(gps_filter_x_right + x_offset, -gps_filter_y_right + y_offset, '*m');

grid on;
legend('Bus Route', 'Direction', 'Detected Left Turn', 'Detected Right Turn');


% Confusion Matrix and ROC curve
TPR_set = [];
FPR_set = [];
P_set = [];
R_set = [];

con_imu_ts = imu_ts;
con_imu_label = imu_label;
con_imu_label(con_imu_label < 4) = 1.5;
con_imu_label(con_imu_label > 4) = 2;
con_imu_label(con_imu_label == 4) = 1;

con_imu_predict = alpha_max_idx_filter';

% left 
TP = sum(con_imu_label == 1.5 & con_imu_predict == 1.5);
FP = sum(con_imu_label == 1 & con_imu_predict == 1.5);
TN = sum(con_imu_label == 1 & con_imu_predict == 1);
FN = sum(con_imu_label == 1.5 & con_imu_predict == 1);

% TPR
TPR_set = [TPR_set, true_positive_rate(TP, FP, FN, TN)];
% FPR
FPR_set = [FPR_set, false_positive_rate(TP, FP, FN, TN)];
% Precision 
P_set = [P_set, precision(TP, FP, FN, TN)];
% recall
R_set = [R_set, recall(TP, FP, FN, TN)];

% right 
TP = sum(con_imu_label == 2 & con_imu_predict == 2);
FP = sum(con_imu_label == 1 & con_imu_predict == 2);
TN = sum(con_imu_label == 1 & con_imu_predict == 1);
FN = sum(con_imu_label == 2 & con_imu_predict == 1);

% TPR
TPR_set = [TPR_set, true_positive_rate(TP, FP, FN, TN)];
% FPR
FPR_set = [FPR_set, false_positive_rate(TP, FP, FN, TN)];
% Precision 
P_set = [P_set, precision(TP, FP, FN, TN)];
% recall
R_set = [R_set, recall(TP, FP, FN, TN)];

con_imu_label(con_imu_label == 2) = 1.5;
con_imu_predict(con_imu_predict == 2) = 1.5;

%con_imu_mix = (con_imu_label == con_imu_predict);

% left and right
TP = sum(con_imu_label == 1.5 & con_imu_predict == 1.5);
FP = sum(con_imu_label == 1 & con_imu_predict == 1.5);
TN = sum(con_imu_label == 1 & con_imu_predict == 1);
FN = sum(con_imu_label == 1.5 & con_imu_predict == 1);

% TPR
TPR_set = [TPR_set, true_positive_rate(TP, FP, FN, TN)];
% FPR
FPR_set = [FPR_set, false_positive_rate(TP, FP, FN, TN)];
% Precision 
P_set = [P_set, precision(TP, FP, FN, TN)];
% recall
R_set = [R_set, recall(TP, FP, FN, TN)];

%confusion_matrix = [TP, FP; FN, TN];

%fig_confusion = figure;
%plot(con_imu_ts(imu_start_idx:imu_end_idx), con_imu_label(imu_start_idx:imu_end_idx));
%hold on;
%plot(con_imu_ts(imu_start_idx:imu_end_idx), 0.5 * con_imu_predict(imu_start_idx:imu_end_idx), 'r');
%plot(con_imu_ts(imu_start_idx:imu_end_idx), 0.4 * con_TP(imu_start_idx:imu_end_idx), 'g');
%plot(con_imu_ts(imu_start_idx:imu_end_idx), 0.3 * con_FP(imu_start_idx:imu_end_idx), 'k');
%plot(con_imu_ts(imu_start_idx:imu_end_idx), 0.2 * con_TN(imu_start_idx:imu_end_idx), 'm');
%plot(con_imu_ts(imu_start_idx:imu_end_idx), 0.1 * con_FN(imu_start_idx:imu_end_idx), 'y');

roc_curve(TPR_set, FPR_set);
pr_curve(P_set, R_set);
