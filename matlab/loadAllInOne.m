clear all;

filename = '../simulation/logall-'
fid = fopen(filename, 'r')

imucounter = 1

tline = fgetl(fid);
while ischar(tline)
  fprintf(1, '\r%s\n\n', tline);
  st = lua2mat(tline);
  if strcmp(st.type, 'imu')
  time = st.timestamp;
  imu(imucounter, :) = [st.r, st.p, st.y, st.wr, st.wp, st.wy, st.ax, st.ay, st.az];
  imucounter = imucounter + 1;
  end
  tline = fgetl(fid);
end
fclose(fid)
