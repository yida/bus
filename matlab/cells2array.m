function a = cells2array(c, field_name)
    c_size = numel(c);
    for i = 1 : c_size
        if isfield(c{i}, field_name) == 0
            error('Not consistent')
        end
        contain = c{i}.(field_name);
        if ischar(contain) > 0 
          a{i} = c{i}.(field_name);
        else
          a(i) = c{i}.(field_name);
        end
    end
end
