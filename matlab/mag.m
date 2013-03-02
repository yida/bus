
hold on;
origin = [0 0 0];
x = 0;
y = 0;
z = 0;

Rz = rotz(pi/3);
Ry = roty(pi/4);
R = Rz(1:3,1:3);

v1 = [1, 0, 0];
v2 = [0, 1, 0];
v3 = [0, 0, 1];
% 
v1 = R * v1'
v2 = R * v2'
v3 = R * v3'

quiver3(x,y,z, v1(1), v1(2), v1(3), 'r'); % X
quiver3(x,y,z, v2(1), v2(2), v2(3), 'b'); % Y
quiver3(x,y,z, v3(1), v3(2), v3(3), 'y'); % Z
hold off;
grid on;
axis([-2 2 -2 2 -2 2]);

