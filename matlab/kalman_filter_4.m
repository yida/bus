
gps_x_filter = gps_x;
gps_y_filter = gps_y;
gps_vx_filter = zeros(size(gps_x));
gps_vy_filter = zeros(size(gps_y));

mu = [gps_x_filter(1); gps_y_filter(1); gps_vx_filter(1); gps_vy_filter(1)];
Cov = eye(numel(mu));
R = diag([0.01^2, 0.01^2, 0.1^2, 0.1^2]);
C = [1 0 0 0; 0 1 0 0];
Q = diag([0.1^2 0.1^2]);

for i = 2 : numel(gps_ts)
  delta_t = gps_ts(i) - gps_ts(i-1);
  A = [1 0 delta_t 0; 0 1 0 delta_t; 0 0 1 0; 0 0 0 1];
  mu = A * mu;
  Cov = A * Cov * A' + R;
  K = Cov * C' * (C * Cov * C' + Q)^(-1);
  mu = mu + K * ([gps_x(i); gps_y(i)] - C * mu);
  gps_x_filter(i) = mu(1);
  gps_y_filter(i) = mu(2);
  gps_vx_filter(i) = mu(3);
  gps_vy_filter(i) = mu(4);
  Cov = (eye(4) - K * C) * Cov;
end

figure;
plot(gps_x, gps_y, '^');
hold on;
plot(gps_x_filter, gps_y_filter, 'r>');
grid on;
