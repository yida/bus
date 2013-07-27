function centralized = centralize(x, y)
    I = floor(numel(x) / 2);
    [C, min_I] = min(y);
    [C, max_I] = max(y);

    centralized = zeros(size(y));
    for j = 1 : numel(x)
      if y(I) > 0
        centralized(j) = x(j) - x(max_I);
      else
        centralized(j) = x(j) - x(min_I);
      end
    end
end
