
filename = '../data/010213180247/imuPruned-02.08.2013.09.56.04-0'
fid = fopen(filename, 'r')

imucounter = 1

tline = fgetl(fid);
while ischar(tline)
%  fprintf(1, '%s\n\n', tline);
  st = lua2mat(tline)
  time = st.timstamp
  imu(imucounter, :) = [st.r, st.p, st.y, st.wr, st.wp, st.wy, st.ax, st.ay, st.az];
  imucounter = imucounter + 1;
  tline = fgetl(fid);
end
fclose(fid)
