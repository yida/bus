clear all;
close all;

datapath = '../data/philadelphia/211212164337.00/';
datapath = '../data/philadelphia/150213185940.20/';
datapath = '../data/philadelphia/191212190259.60/';

gps = load_data_msgpack([datapath, 'gpsLocalMP']);
label = load_data_msgpack([datapath, 'labelMP']);

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

%{
gps_idx = 1;
label_idx = 1;
gps_label = zeros(size(gps_lat));
for i = gps_ts_start : 0.000001 : gps_ts_end
  if gps_idx <= size(gps_lat) & abs(gps_ts(gps_idx) - i) < 0.000001
%    fprintf(1, 'GPS sample %10.6f\n', i);
    gps_idx = gps_idx + 1;
  end
  if label_idx <= size(label_ts) & abs(label_ts(label_idx) - i) < 0.000001
%    fprintf(1, 'Label sample %10.6f\n', i);
    gps_label(gps_idx) = label_ts(label_idx);
    label_idx = label_idx + 1;
  end
end
%}

%for i = 1 : size(label_ts, 2)
%  fprintf(1, '%10.6f\n', label_ts(i));
%end

% binary search
tic;
gps_label = zeros(size(label_ts));
for i = 1 : size(label_ts, 2)
  ts = label_ts(i);
  start_idx = 1;
  end_idx = size(gps_ts, 2);
  mid_idx = floor((start_idx + end_idx) / 2);
  while abs(gps_ts(mid_idx) - ts) > 0.000001 & (end_idx - start_idx) > 1
%    fprintf(1, '%10.6f %10.6f %d %d\n', gps_ts(mid_idx), ts, end_idx, start_idx);
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

figure; 
plot(gps_x, gps_y, '.');
hold on;
plot(gps_x(gps_label), gps_y(gps_label), 'r*');
hold off;

grid on;
axis equal;
