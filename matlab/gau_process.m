imu_cells;

imu_sample = imu_cells{1};


[C, I] = max(imu_sample.wy);
fprintf(1, 'peak time stamp %10.6f\n', imu_sample.ts(I));

centralized_ts = zeros(size(imu_sample.ts));
for i = 1 : numel(imu_sample.ts)
  centralized_ts(i) = imu_sample.ts(i) - imu_sample.ts(I);
end

%[sigma, mu] = gaussfit(imu_sample.ts, imu_sample.wy);
%[sigma, mu, A] = mygaussfit(imu_sample.ts, imu_sample.wy);
%[sigma, mu] = normfit(imu_sample.wy);

%[mu, sigma] = normfit(imu_sample.wy)

% MLE
%mu_mle = sum(imu_sample.wy) / numel(imu_sample.ts);
%sigma_mle = sum((imu_sample.wy - ones(size(imu_sample.wy)).*mu_mle).^2) / numel(imu_sample.wy);

%mu = mu_mle
%sigma = sigma_mle;

%figure;
%%A = 1;
%xp = -1:0.001:1;
%yp = A .* 1./(sqrt(2.*pi).* sigma ).* exp( - (xp-mu).^2 / (2.*sigma.^2));

p = polyfit(centralized_ts, imu_sample.wy, 2);
x = centralized_ts;
f = polyval(p, x);

plot(centralized_ts, imu_sample.wy, '.');
hold on;
plot(x, f, 'r');
grid on;
