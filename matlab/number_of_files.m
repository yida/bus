function file_lists = number_of_files(path, filename_template)
  files = dir(path);
  file_lists = {};
  file_num = 0;
  for i = 1 : size(files, 1)
    if strfind(files(i).name, filename_template) > 0
      file_num = file_num + 1;
    end
  end
  for file_cnt = 1 : file_num
    file_lists{file_cnt} = [path, filename_template, num2str(file_cnt - 1)];
    if exist(file_lists{file_cnt}, 'file') == 0
      error(['file not consistent ', file_lists{file_cnt}]);
    end
  end
end
