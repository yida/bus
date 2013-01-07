function plot_circle(circle, handle)

  if nargin < 2
    handle = gca;
  end
                 
  if isfield(circle, 'arcStart') == 1
    arcS = circle.arcStart;
  else arcS = 0; end

  if isfield(circle, 'arcEnd') == 1
    arcE = circle.arcEnd;
  else arcE = 2 * pi; end

  if isfield(circle, 'color') == 1
    color = circle.color;
  else color = 'k'; end

  nseg = 120;
  theta = arcS : (2 * pi / nseg) : arcE;
  cx = circle.cx; cy = circle.cy; r = circle.r;
  pline_x = r * cos(theta) + cx;
  pline_y = r * sin(theta) + cy;
  plot(handle, pline_x, pline_y, color);
 
