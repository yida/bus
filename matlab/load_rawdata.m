function file_lines = load_rawdata(file_lists)
  file_lines = {};
  for file_cnt = 1 : size(file_lists, 2)
    filename = file_lists{file_cnt};
    fid = fopen(filename);
    
    tline = fgets(fid);
    while ischar(tline)
      fprintf(1, '%s\n', tline);
      tline = fgets(fid);
    end
  end 
end
