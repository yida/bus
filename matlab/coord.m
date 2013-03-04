function coord(x, y, z, R, heading)

  origin = [0 0 0];
  
  % Rz = rotz(pi/3);
  % Ry = roty(pi/4);
  % R = Rz(1:3,1:3);
  
  magR = rotz(heading);

  v1 = [2, 0, 0];
  v2 = [0, 2, 0];
  v3 = [0, 0, 2];
   
  vm = magR(1:3, 1:3) * v1';

  v1 = R * v1';
  v2 = R * v2';
  v3 = R * v3';

  
  quiver3(x,y,z, v1(1), v1(2), v1(3), 'r'); % X
  hold on;
  quiver3(x,y,z, v2(1), v2(2), v2(3), 'b'); % Y
  quiver3(x,y,z, v3(1), v3(2), v3(3), 'y'); % Z
  quiver3(x,y,z, vm(1), vm(2), vm(3), 'k'); % mag
  hold off;
  grid on;
  axis([-2 2 -2 2 -100 50]);
  drawnow 
