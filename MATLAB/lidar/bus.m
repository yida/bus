function BUS = bus(cx, cy, theta)

  BUS.name = 'rectangle';
  BUS.cx = cx;
  BUS.cy = cy;
  BUS.theta = theta;
  BUS.w = 2.6;
  BUS.h = 12.4;
  BUS.fw = 2.7;
  BUS.rw = 3.65;
  BUS.L = 12.4 - BUS.fw - BUS.rw;
  BUS.color = 'b';
  BUS.kx = BUS.cx - (BUS.h/2 - BUS.rw) * sin(BUS.theta);
  BUS.ky = BUS.cy - (BUS.h/2 - BUS.rw) * cos(BUS.theta);
  BUS.ktheta = pi / 2 - BUS.theta;
  BUS.u_s = 2.235;
  BUS.u_phi = 0;

