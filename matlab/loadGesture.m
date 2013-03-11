clear all;

for i = 1 : 10
  gesturesampleid = sprintf('%d',i);
  gesturesamplesuffix = '03.06.2013.10.52.54-0';
  gesturename = 'hammer';
  filename = strcat('../project3/', gesturename, '/',...
              'gesture', gesturesampleid, '-',...
              gesturesamplesuffix);
  fid = fopen(filename, 'r');
   
  imucounter = 1;
  time = zeros(1,1);
  imu = zeros(1, 6);
  % 
  tline = fgetl(fid);
  while ischar(tline)
  %  fprintf(1, '\r%s\n\n', tline);
     st = lua2mat(tline);
     if strcmp(st.type, 'imu')
      time(imucounter, :) = st.timestamp;
      imu(imucounter, :) = [st.wx, st.wy, st.wz, st.ax, st.ay, st.az];
      imucounter = imucounter + 1;
     end
     tline = fgetl(fid);
  end
  fclose(fid);
  
  figure;
  plot(time, imu(:,1), '-*', time, imu(:,2), '-*', time, imu(:,3), '-*');
  grid on;

end
