close all;

% sync imu and gps
obs = sync_data(imu_ts, gps_ts);
num_obs = numel(obs);

theta0 = 0;
omega0 = 0;
omega_acc0 = 0;
x0 = 0;
y0 = 0;
vx0 = 0;
vy0 = 0;

%mu = [x0; y0; theta0; v0; omega0]; 
%mu = [theta0; omega0; omega_acc0]; 
%mu = [theta0; omega0]; 
mu = [theta0; omega0; omega_acc0; x0; y0; v0]; 
Cov = eye(numel(mu));
%C = [0, 1, 0, 0, 0, 0];
C_imu = [0, 1, 0, 0, 0, 0];
C_gps = [0 0 0 1 0 0; 0 0 0 0 1 0];

dim = numel(mu);

% scale parameters
alpha = 0.40; % scale of sigma points from the center of G
kappa = 47.8;
% encode additional knowledge
beta = 2;
lambda = alpha^2 * (dim + kappa) - dim;
gamma = sqrt(dim + lambda);

wt_m = ones(1, 2 * dim + 1) * 1 / (2 * (dim + gamma));
wt_c = ones(1, 2 * dim + 1) * 1 / (2 * (dim + gamma));
wt_m(1) = gamma / (dim + gamma);
wt_c(1) = gamma / (dim + gamma) + (1 - alpha^2 + beta);

R = diag([0.1^2; 0.12^2; 0.01^2; .15^2; .15^2; 0.01^2]);
Q_imu = 1^2;
Q_gps = diag([32^2; 32^2]);

Chi = zeros(dim, 2 * dim + 1);
Chi_est = zeros(dim, 2 * dim + 1);

%num_obs = 10000;
result = zeros(dim + 1, num_obs);
result_counter = 1;
result(1, result_counter) = obs{1}.ts;
result(2:end, result_counter) = mu;

%Chi = [mu, bsxfun(@plus, mu, gamma .* chol(Cov)), bsxfun(@minus, mu, gamma .* chol(Cov))];
%plot_gaussian(mu, Cov);
%hold on;
%plot(Chi(1, :), Chi(2, :), '*');
%grid on;
%axis equal;

last_ts = obs{1}.ts;
tic;
for cnt = 2 : num_obs
  delta_t = obs{cnt}.ts - last_ts;
  if obs{cnt}.imu_idx > 0 
    % Generate Sigma pointes
    Chi = [mu, bsxfun(@plus, mu, gamma .* chol(Cov)), bsxfun(@minus, mu, gamma .* chol(Cov))];
    % Dynamic update with Sigma points -> Chi estimate
    for chi_idx = 1 : size(Chi, 2)
      %theta
      Chi(1, chi_idx) = Chi(1, chi_idx) + Chi(2, chi_idx) * delta_t + Chi(3, chi_idx) * delta_t^2 * 0.5;
      %omega
      Chi(2, chi_idx) = Chi(2, chi_idx) + Chi(3, chi_idx) * delta_t;
      % x
      Chi(4, chi_idx) = Chi(4, chi_idx) + Chi(6, chi_idx) * delta_t * cos(Chi(1, chi_idx));
      % y
      Chi(5, chi_idx) = Chi(5, chi_idx) + Chi(6, chi_idx) * delta_t * sin(Chi(1, chi_idx));
    end 
    mu_est = sum(Chi .* repmat(wt_m, size(Chi, 1),1), 2);  
    Cov_est = zeros(numel(mu), numel(mu));
    for chi_idx = 1 : 2 * dim + 1
      Cov_est = Cov_est + wt_c(chi_idx) * (Chi(:, chi_idx) - mu_est) * (Chi(:, chi_idx) - mu_est)';
    end
    Cov_est = Cov_est + R;

    % estimated sigma points
    Chi_est = [mu_est, bsxfun(@plus, mu_est, gamma .* chol(Cov_est)), bsxfun(@minus, mu_est, gamma .* chol(Cov_est))];

    % estimated observation
    Z_est = C_imu * Chi_est;

    z_est = sum(Z_est .* repmat(wt_m, size(Z_est, 1),1), 2);  
    % estimated observation covariance
    S_est = zeros(numel(z_est), numel(z_est));
    for z_idx = 1 : 2 * dim + 1
      S_est = S_est + wt_c(z_idx) * (Z_est(:, z_idx) - z_est) * (Z_est(:, z_idx) - z_est)';
    end
    S_est = S_est + Q_imu;

    % Cross covariance
    Cross_est = zeros(numel(mu_est), numel(z_est));
    for idx = 1 : 2 * dim + 1
      Cross_est = Cross_est + wt_c(idx) * (Chi_est(:, idx) - mu_est) * (Z_est(:, idx) - z_est)';
    end
    % Kalman Gain
    K = Cross_est * inv(S_est); 

    % Generate obs vector
    z_obs = imu_wy(obs{cnt}.imu_idx);

    mu = mu_est + K * (z_obs - z_est);
    Cov = Cov_est - K * S_est * K';

    result_counter = result_counter + 1;
    result(1, result_counter) = obs{cnt}.ts;
    result(2:end, result_counter) = mu;

    last_ts = obs{cnt}.ts;
  elseif obs{cnt}.gps_idx > 0
    % estimated sigma points
    Chi_est = [mu_est, bsxfun(@plus, mu_est, gamma .* chol(Cov_est)), bsxfun(@minus, mu_est, gamma .* chol(Cov_est))];

    % estimated observation
    Z_est = C_gps * Chi_est;

    z_est = sum(Z_est .* repmat(wt_m, size(Z_est, 1),1), 2);  
    % estimated observation covariance
    S_est = zeros(numel(z_est), numel(z_est));
    for z_idx = 1 : 2 * dim + 1
      S_est = S_est + wt_c(z_idx) * (Z_est(:, z_idx) - z_est) * (Z_est(:, z_idx) - z_est)';
    end
    S_est = S_est + Q_gps;

    % Cross covariance
    Cross_est = zeros(numel(mu_est), numel(z_est));
    for idx = 1 : 2 * dim + 1
      Cross_est = Cross_est + wt_c(idx) * (Chi_est(:, idx) - mu_est) * (Z_est(:, idx) - z_est)';
    end
    % Kalman Gain
    K = Cross_est * inv(S_est); 

    % Generate obs vector
    z_obs = [gps_x(obs{cnt}.gps_idx); gps_y(obs{cnt}.gps_idx)];

    mu = mu_est + K * (z_obs - z_est);
    Cov = Cov_est - K * S_est * K';

    result_counter = result_counter + 1;
    result(1, result_counter) = obs{cnt}.ts;
    result(2:end, result_counter) = mu;
  end
end
toc

figure;
plot(result(1, :), result(3, :));
hold on;
plot(result(1, :), result(2, :), 'r');
%plot(result(1, :), cos(result(2, :)), 'k');
%plot(result(1, :), sin(result(2, :)), 'm');
%plot(result(1, :), result(4, :) + 0.3, 'k');
grid on;
figure;
plot(result(5, :), result(6, :), '*');
grid on;
