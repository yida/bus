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
                                              imu_r, imu_p, imu_y, imu_wr, imu_wp, imu_wy,...
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
imu_wy_line = plot(imu_ts(imu_start_idx:imu_end_idx), imu_wy(imu_start_idx:imu_end_idx));
hold on;
imu_label_line = plot(imu_ts(imu_start_idx:imu_end_idx), imu_label_mask(imu_start_idx:imu_end_idx), 'r');
hold off;
grid on;

dcm_gps_obj = datacursormode(fig_gps);
%dcm_gps_label_obj = datacursormode(fig_gps);
dcm_imu_obj = datacursormode(fig_imu);
set(dcm_gps_obj, 'UpdateFcn', {@dc_gps_imu_update, dcm_gps_obj, dcm_imu_obj,...
                                gps_x, gps_y, gps_ts, gps_lat, gps_lon, imu_ts, imu_wy});
set(dcm_imu_obj, 'UpdateFcn', {@dc_gps_imu_update, dcm_gps_obj, dcm_imu_obj,...
                                gps_x, gps_y, gps_ts, gps_lat, gps_lon, imu_ts, imu_wy});

hTarget_wy = handle(imu_wy_line);
hTarget_gps = handle(gps_line);
%hTarget_gps_label = handle(gps_label_line);

hDatatip_wy = dcm_imu_obj.createDatatip(hTarget_wy);
hDatatip_gps = dcm_gps_obj.createDatatip(hTarget_gps);
%hDatatip_gps_label = dcm_gps_label_obj.createDatatip(hTarget_gps_label);

state_set = {'left_turn', 'right_turn', 'straight'};

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
%         gaussmf(imu_wy(i), [hmm.obs_prob_sigma(s), hmm.obs_prob_mu(s)]);
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
    obs_prob(s) = -1/(sqrt(2 * pi * hmm.obs_prob_sigma(s))) *...
         gaussmf(imu_wy(i), [hmm.obs_prob_sigma(s), hmm.obs_prob_mu(s)]);
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

fig_alpha = figure;
plot(imu_ts(imu_start_idx:imu_end_idx), imu_wy(imu_start_idx:imu_end_idx));
hold on;
plot(imu_ts(imu_start_idx:imu_end_idx), imu_label_mask(imu_start_idx:imu_end_idx), 'r');
plot(imu_ts(imu_start_idx:imu_end_idx), alpha_max_idx(imu_start_idx:imu_end_idx));
hold off;
grid on;
