function [start_out_idx, end_out_idx] = range2index(array, start_value, end_value)
  % Assume input array are sorted numbers
  % Given start value and end value
  % return start idx and end idx

  % binary search
    ts = start_value;
    start_idx = 1;
    end_idx = numel(array);
    mid_idx = floor((start_idx + end_idx) / 2);
    while abs(array(mid_idx) - ts) > 0.000001 & (end_idx - start_idx) > 1
      if ts > array(mid_idx) 
        start_idx = mid_idx;
      else
        end_idx = mid_idx;
      end
      mid_idx = floor((start_idx + end_idx) / 2);
    end
    start_out_idx = mid_idx;

    ts = end_value;
    start_idx = 1;
    end_idx = numel(array);
    mid_idx = floor((start_idx + end_idx) / 2);
    while abs(array(mid_idx) - ts) > 0.000001 & (end_idx - start_idx) > 1
      if ts > array(mid_idx) 
        start_idx = mid_idx;
      else
        end_idx = mid_idx;
      end
      mid_idx = floor((start_idx + end_idx) / 2);
    end
    end_out_idx = mid_idx;
end
