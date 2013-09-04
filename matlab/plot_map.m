gps_lat = cells2array(gps, 'latitude');
gps_lon = cells2array(gps, 'longtitude');
gps_ts  = cells2array(gps, 'timestamp');
gps_x  = cells2array(gps, 'x');
gps_y  = cells2array(gps, 'y');

gps_start_idx = 1;
gps_end_idx = size(gps_ts, 2);

fig_gps = figure; 
pos_fig = get(fig_gps, 'Position');

set(fig_gps, 'Position', [pos_fig(1), pos_fig(2), 800, 600]);

% match scale
% scale = 0.93;  
% x_offset = 360;
% y_offset = 970;

%[gps_start_idx, gps_end_idx] = range2index(gps_ts, 946684970.550000, 946685185.550000);

roadmap = imread([datapath, 'roadmap.jpeg']);
plot_map_gps(roadmap, gps_x(gps_start_idx:gps_end_idx),...
                      gps_y(gps_start_idx:gps_end_idx), x_offset, y_offset, scale);

%figure;
%satellite = imread([datapath, 'satellite.jpeg']);
%plot_map_gps(satellite, gps_x(gps_start_idx:gps_end_idx),...
%                      gps_y(gps_start_idx:gps_end_idx), x_offset, y_offset, scale);
%
%figure;
%hybrid = imread([datapath, 'hybrid.jpeg']);
%plot_map_gps(hybrid, gps_x(gps_start_idx:gps_end_idx),...
%                      gps_y(gps_start_idx:gps_end_idx), x_offset, y_offset, scale);
%
