x = -10:0.1:10;
y1 = gaussmf(x, [-0.23450246305419, -0.50034318893977]);
y2 = gaussmf(x, [0.28053916581892, 0.43434574265323]);
figure; plot(x, y1)
figure; plot(x, y2)
grid on



