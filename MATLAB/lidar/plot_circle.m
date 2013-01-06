function plot_circle(circle)

  nseg = 60;
  theta = 0 : (2 * pi / nseg) : (2 * pi);
  cx = circle.cx; cy = circle.cy; r = circle.r;
  pline_x = r * cos(theta) + cx;
  pline_y = r * sin(theta) + cy;
  plot(pline_x, pline_y, 'k');
 
