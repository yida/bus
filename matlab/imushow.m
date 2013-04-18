figure;

% tstart = 1;
% tend = floor(size(imudata, 2));
% % plot(imudata(10, tstart:tend), imudata(6, tstart:tend));
% % hold on;
% % plot(imudata(10,tstart:tend), imudata(11,tstart:tend) * 2,'r');
% % plot(imudata(10,tstart:tend), imudata(12,tstart:tend),'y');
% % grid on;
% 
% plot(tstart:tend, imudata(6, tstart:tend));
% hold on;
% plot(tstart:tend, imudata(11,tstart:tend) * 2,'r');
% plot(tstart:tend, imudata(12,tstart:tend),'y');
% grid on;

tstart = 1;
tend = floor(size(gpspos, 2));
% plot(imudata(10, tstart:tend), imudata(6, tstart:tend));
% hold on;
% plot(imudata(10,tstart:tend), imudata(11,tstart:tend) * 2,'r');
% plot(imudata(10,tstart:tend), imudata(12,tstart:tend),'y');
% grid on;

% plot(tstart:tend, gpspos(5, tstart:tend));
% hold on;
% plot(tstart:tend, imudata(11,tstart:tend) * 2,'r');
% plot(tstart:tend, imudata(12,tstart:tend),'y');
% grid on;

plot(gpspos(1,:), gpspos(2,:), '.');
axis equal;
grid on;