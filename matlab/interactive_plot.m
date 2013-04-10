
fig = figure;
hold on;
%endt = pos(4,end);
%idf = find(gpspos(4,:)>=endt);
%ide = find(gpspos(4,:)<=endt);
%idf(1);
%ide(end);
%idx = floor((idf(1) + ide(end))/2);
idx = floor(size(gpspos, 2));
% %idx = size(gpspos, 2);
% heading = gpspos(7, 1:idx);
cosheading = cos(gpspos(6,1:idx)) .* gpspos(5, 1:idx) * 10;
sinheading = sin(gpspos(6,1:idx)) .* gpspos(5, 1:idx) * 10;
% yaw = pos(7, 1:end);
% cosyaw = cos(pos(7,1:end));
% sinyaw = sin(pos(7,1:end));

% plot(pos(1,1:end), pos(2,1:end), 'y.');
plot(gpspos(1,1:idx), gpspos(2,1:idx), 'r.');
% quiver(gpspos(1,1:idx), gpspos(2,1:idx), cosheading, sinheading);
% quiver(pos(1,1:end), pos(2,1:end), cosyaw, sinyaw, 'r');

% plot(gpspos(1,:), gpspos(2,:), 'r.');
% plot(gpslabel(1,:), gpslabel(2,:), 'm^');
% plot(label(1,:), label(2,:), 'b*');
hold off;
grid on;
axis equal;

dcm_obj = datacursormode(fig);
set(dcm_obj, 'UpdateFcn', {@myupdatefcn, pos, gpspos, imudata});
