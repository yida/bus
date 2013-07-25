function centralized = centralize(x, y)
    I = floor(numel(x) / 2);

    centralized = zeros(size(y));
    for j = 1 : numel(x)
      centralized(j) = x(j) - x(I);
    end
end
