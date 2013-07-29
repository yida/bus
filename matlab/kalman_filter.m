imu_wy_acc = zeros(size(imu_wy));
for i = 2 : numel(imu_wy)
  imu_wy_acc(i) = (imu_wy(i) - imu_wy(i - 1)) / (imu_ts(i) - imu_ts(i - 1));
end

%plotyy(imu_ts, imu_wy, imu_ts, imu_wy_acc);
%grid on;

imu_wy_filter = imu_wy;
imu_wy_acc_filter = zeros(size(imu_wy));

mu = [imu_wy(1), 0]';
Cov = [1, 0; 0, 1];
R = [0.01^2, 0; 0, 0.01^2];
C = [1, 0];
Q = 1^2;

for i = 2 : numel(imu_wy)
  delta_t = imu_ts(i) - imu_ts(i-1);
  A = [1, delta_t; 0, 1];
  mu = A * mu;
  Cov = A * Cov * A' + R;
  K = Cov * C' * (C * Cov * C' + Q)^(-1);
  mu = mu + K * (imu_wy(i) - C * mu);
  imu_wy_filter(i) = mu(1);
  imu_wy_acc_filter(i) = mu(2);
  Cov = (eye(2) - K * C) * Cov;
end

figure;
plot(imu_ts, imu_wy_filter)
hold on;
plot(imu_ts, imu_wy_acc_filter + 0.7, 'r');
plot(imu_ts, imu_wy - 0.3, 'k');
hold off;
grid on;
