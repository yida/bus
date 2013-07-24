function rela = get_relative_time(time)
  rela = zeros(size(time));
  for i = 2 : numel(time)
    rela(i) = time(i) - time(1);
  end
end
