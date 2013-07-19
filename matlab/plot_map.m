gps_lat = cells2array(gps, 'latitude');
gps_lon = cells2array(gps, 'longtitude');
gps_ts  = cells2array(gps, 'timestamp');
gps_x  = cells2array(gps, 'x');
gps_y  = cells2array(gps, 'y');

gps_start_idx = 1;
gps_end_idx = size(gps_ts, 2);

fig_gps = figure; 

% match scale
scale = 0.92;
x_offset = -110;
y_offset = 380;

datapath = '../data/philadelphia/211212165622.00/';
roadmap = imread([datapath, 'satellite.jpeg']);
roadmap = imresize(roadmap, scale);
h_img = image(roadmap);
%axis equal;
hold on;

h = plot(gps_x(gps_start_idx:gps_end_idx) + x_offset, -gps_y(gps_start_idx:gps_end_idx) + y_offset);
%set(gca, 'YDir', 'reverse');
%plot(h_img, gps_x(gps_start_idx:gps_end_idx), gps_y(gps_start_idx:gps_end_idx), '.');
%plot(h_img, gps_x(gps_label), gps_y(gps_label), 'r*');
hold off;

grid on;
axis equal;
