function a = cells2array(c, field_name)
    c_size = numel(c);
    a = zeros(1, c_size);
    for i = 1 : c_size
        if isfield(c{i}, field_name) == 0
            error('Not consistent')
        end
        a(i) = c{i}.(field_name);
    end
end