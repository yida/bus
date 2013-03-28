
fig = figure;
hold on;
endt = pos(4,end);
idf = find(gpspos(4,:)>=endt);
ide = find(gpspos(4,:)<=endt);
idf(1);
ide(end);
idx = floor((idf(1) + ide(end))/2);
heading = gpspos(5, 1:idx);
cosheading = cos(gpspos(5,1:idx));
sinheading = sin(gpspos(5,1:idx));

%plot(pos(1,:), pos(2,:), 'b');
plot(gpspos(1,1:idx), gpspos(2,1:idx), 'r.');
quiver(gpspos(1,1:idx), gpspos(2,1:idx), cosheading, sinheading);

%plot(gpspos(1,:), gpspos(2,:), 'r.');
%plot(gpslabel(1,:), gpslabel(2,:), 'm^');
%plot(label(1,:), label(2,:), 'b*');
hold off;
grid on;
axis equal;

dcm_obj = datacursormode(fig);
set(dcm_obj, 'UpdateFcn', {@myupdatefcn, pos, gpspos, imudata});
