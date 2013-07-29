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

% process label array
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
imu_label_line = plot(imu_ts(imu_start_idx:imu_end_idx), imu_label(imu_start_idx:imu_end_idx) - 2, 'r');
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

state_set = {'left_turn', 'right_turn', 'straight'};


hmm = {};

% Generate init prob
init_prob = zeros(1, numel(state_set));
for i = 1 : numel(imu_label)
  init_prob(imu_label(i)) = init_prob(imu_label(i)) + 1;
end
init_prob = init_prob ./ numel(imu_label);

% Generate Transit prob
transit_prob = zeros(numel(state_set), numel(state_set));
for i = 1 : numel(imu_label)
  cur_label = imu_label(i);
  pre_label = imu_prelabel(i);
  if pre_label ~= -1
    transit_prob(cur_label, pre_label) = transit_prob(cur_label, pre_label) + 1;
  end
end
transit_prob_sum = sum(transit_prob, 2);
transit_prob = bsxfun(@rdivide, transit_prob, transit_prob_sum);

% Generate obs prob
obs_prob_mu = zeros(2, numel(state_set));
obs_prob_sigma = zeros(2, 2, numel(state_set));
obs_prob_counter = zeros(1, numel(state_set));

for i = imu_start_idx : imu_end_idx
  obs_prob_counter(imu_label(i)) = obs_prob_counter(imu_label(i)) + 1;
  obs_prob_mu(:, imu_label(i)) = obs_prob_mu(:, imu_label(i)) + [imu_wy_filter(i); imu_wy_acc_filter(i)];      
end
obs_prob_mu = bsxfun(@rdivide, obs_prob_mu, obs_prob_counter);

obs_prob_counter = zeros(1, numel(state_set));
for i = imu_start_idx : imu_end_idx
  obs_prob_counter(imu_label(i)) = obs_prob_counter(imu_label(i)) + 1;
  obs_prob_sigma(:, :, imu_label(i)) = obs_prob_sigma(:, :, imu_label(i)) +...
      ([imu_wy_filter(i); imu_wy_acc_filter(i)] - obs_prob_mu(:, imu_label(i))) *...
      ([imu_wy_filter(i); imu_wy_acc_filter(i)] - obs_prob_mu(:, imu_label(i)))';
end
for i =  1 : size(obs_prob_sigma, 3)
  obs_prob_sigma(:, :, i) = obs_prob_sigma(:, :, i) ./ obs_prob_counter(i);
end

hmm.init_prob = init_prob;
hmm.transit_prob = transit_prob;
hmm.obs_prob_mu = obs_prob_mu;
hmm.obs_prob_sigma = obs_prob_sigma;


