figure;

tend = floor(size(imudata, 2));
plot(imudata(10, 1:tend), imudata(6, 1:tend));
hold on;
plot(imudata(10,:), imudata(11,:) * 2,'r');
plot(imudata(10,:), imudata(12,:),'y');
grid on;