data_path = '../data/rawdata/2012121321/';
type_name = 'gps';
date_stamp = '12311901';
filename_temp = [type_name, date_stamp];
file_lists = number_of_files(data_path, filename_temp);
file_lines = load_rawdata(file_lists);

