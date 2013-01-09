function time_matlab_string = epoch2date(time)
  time_unix = time * 1000;
  time_reference = datenum('1970', 'yyyy');
  time_matlab = time_reference + time_unix / 8.64e7;
  time_matlab_string = datestr(time_matlab, 'yyyymmdd HH:MM:SS.FFF');

