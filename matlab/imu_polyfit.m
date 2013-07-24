function [x, y] = imu_polyfit(sample_x, sample_y)
%  [C, I] = max(sample_y);
%  centralized_x = zeros(size(sample_x));
%  for i = 1 : numel(sample_x)
%    centralized_x(i) = sample_x(i) - sample_x(I);
%  end
  p = polyfit(sample_x, sample_y, 2);
  x = sample_x;
  y = polyval(p, x);
end
