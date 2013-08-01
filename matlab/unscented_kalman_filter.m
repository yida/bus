close all;

% sync imu and gps
%obs = sync_data(imu_ts, gps_ts);
obs = sync_data(imu_ts, []);
num_obs = numel(obs);

%x0 = 0;
%y0 = 0;
%v0 = 0;

theta0 = 0;
omega0 = 0;
omega_acc0 = 0;

%theta0 = 0.3;
%omega0 = 0.45;
%omega_acc0 = 0.6;

%mu = [x0; y0; theta0; v0; omega0]; 
mu = [theta0; omega0; omega_acc0]; 
Cov = eye(numel(mu));
C = [0, 1, 0];

dim = numel(mu);

% scale parameters
alpha = 1.2;
kappa = .05;
% encode additional knowledge
beta = 2;
lambda = alpha^2 * (dim + kappa) - dim;
gamma = sqrt(dim + lambda);

wt_m = ones(1, 2 * dim + 1) * 1 / (2 * (dim + gamma));
wt_c = ones(1, 2 * dim + 1) * 1 / (2 * (dim + gamma));
wt_m(1) = gamma / (dim + gamma);
wt_c(1) = gamma / (dim + gamma) + (1 - alpha^2 + beta);

%R = diag([50^2, 50^2, 0.01^2, 1^2, 0.01^2]);
R = diag([0.01^2; 0.1^2; 0.05^2]);
%Q = diag([0.5^2, 0.5^2, 1^2]);
Q = 1^2;

Chi = zeros(dim, 2 * dim + 1);
Chi_est = zeros(dim, 2 * dim + 1);

%num_obs = 10000;
result = zeros(dim, num_obs);
result_counter = 1;
result(:, result_counter) = mu;

tic;
for cnt = 2 : num_obs
%for cnt = 2 : 30
%for cnt = 2 : 2
  delta_t = obs{cnt}.ts - obs{cnt - 1}.ts;
  % Generate Sigma pointes
  Chi = [mu, bsxfun(@plus, mu, gamma .* chol(Cov)), bsxfun(@minus, mu, gamma .* chol(Cov))];
  % Dynamic update with Sigma points -> Chi estimate
  for chi_idx = 1 : size(Chi, 2)
%    Chi(1, chi_idx) = Chi(1, chi_idx) + Chi(4, chi_idx) * cos(Chi(3, chi_idx)) * delta_t;
%    Chi(2, chi_idx) = Chi(2, chi_idx) + Chi(4, chi_idx) * sin(Chi(3, chi_idx)) * delta_t;
%    Chi(3, chi_idx) = Chi(3, chi_idx) + Chi(5, chi_idx) * delta_t;
    Chi(1, chi_idx) = Chi(1, chi_idx) + Chi(2, chi_idx) * delta_t + Chi(3, chi_idx) * delta_t^2 * 0.5;
    Chi(2, chi_idx) = Chi(2, chi_idx) + Chi(3, chi_idx) * delta_t;
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
  Z_est = C * Chi_est;

  z_est = sum(Z_est .* repmat(wt_m, size(Z_est, 1),1), 2);  
  % estimated observation covariance
  S_est = zeros(numel(z_est), numel(z_est));
  for z_idx = 1 : 2 * dim + 1
    S_est = S_est + wt_c(z_idx) * (Z_est(:, z_idx) - z_est) * (Z_est(:, z_idx) - z_est)';
  end
  S_est = S_est + Q;

  % Cross covariance
  Cross_est = zeros(numel(mu_est), numel(z_est));
  for idx = 1 : 2 * dim + 1
    Cross_est = Cross_est + wt_c(idx) * (Chi_est(:, idx) - mu_est) * (Z_est(:, idx) - z_est)';
  end
  % Kalman Gain
  K = Cross_est * inv(S_est); 

  % Generate obs vector
%  z_obs = [mu(1); mu(2); mu(3)];    
%  z_obs = mu(2);    
%  if obs{cnt}.imu_idx > 0
  z_obs = imu_wy(obs{cnt}.imu_idx);
%  elseif obs{cnt}.gps_idx > 0
%    z_obs(1) = gps_x(obs{cnt}.gps_idx);
%    z_obs(2) = gps_y(obs{cnt}.gps_idx);
%  end

%  z_obs - z_est
  mu = mu_est + K * (z_obs - z_est);
  Cov = Cov_est - K * S_est * K';

  result(:, result_counter) = mu;
  result_counter = result_counter + 1;
end
toc

%result_x = result(1, :);
%result_y = result(2, :);

%figure;
%plot(gps_x, gps_y);
%figure;
%plot(result_x, result_y, '.');
%grid on;
%axis equal;

figure;
plot(1 : size(result, 2), result(2, :));
hold on;
plot(1 : size(result, 2), result(1, :), 'm');
plot(1 : size(result, 2), result(3, :) + 0.3, 'k');
grid on;
