function plot_map_gps(img, x, y, x_off, y_off, scale)
  img = imresize(img, scale);
  h_img = image(img);
  hold on;
  
  plot(x + x_off, -y + y_off, '.');
  hold off;
  
  grid on;
  axis equal;
end
