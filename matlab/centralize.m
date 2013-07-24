function centralized = centralize(x, y)
    [C, I] = max(y);
    centralized = zeros(size(y));
    for j = 1 : numel(x)
      centralized(j) = x(j) - x(I);
    end
end
