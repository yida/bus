function matched = binary_matching(large, small)
  tic;
  matched = zeros(size(small));
  for i = 1 : size(small, 2)
    value = small(i);
    start_idx = 1;
    end_idx = numel(large);
    mid_idx = floor((start_idx + end_idx) / 2);
    while abs(large(mid_idx) - value) > 0.000001 & (end_idx - start_idx) > 1
      if value > large(mid_idx) 
        start_idx = mid_idx;
      else
        end_idx = mid_idx;
      end
      mid_idx = floor((start_idx + end_idx) / 2);
    end
    matched(i) = mid_idx;
  end
  toc;
end
