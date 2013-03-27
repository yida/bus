fig = figure;
hold on;
plot(pos(1,:), pos(2,:), 'y.');
plot(gpspos(1,:), gpspos(2,:), 'r.');

%plot(gpslabel(1,:), gpslabel(2,:), 'm^');
%plot(label(1,:), label(2,:), 'b*');
hold off;
grid on;
axis equal;

dcm_obj = datacursormode(fig);
set(dcm_obj, 'UpdateFcn', {@myupdatefcn, pos, gpspos, imudata});

