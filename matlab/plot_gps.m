lat = cells2array(gps, 'latitude');
lon = cells2array(gps, 'longtitude');
x = cells2array(gps, 'x');
y = cells2array(gps, 'y');

figure; plot(x, y, '.');
grid on;
axis equal;

% figure; plot(lat, lon);