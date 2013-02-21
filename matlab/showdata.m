bnum = 300;
enum = 5000;
x = bnum : enum;

ax = imu(bnum:enum, 7);
ay = imu(bnum:enum, 8);
az = imu(bnum:enum, 9);
wx = imu(bnum:enum, 4);
wy = imu(bnum:enum, 5);
wz = imu(bnum:enum, 6);
r = imu(bnum:enum, 1);
p = imu(bnum:enum, 2);
y = imu(bnum:enum, 3);


R = [1, 0, 0;0, -1, 0;0,0,-1]
vector = [ax,ay,az];

A = R * vector';
%A = bsxfun(@minus, A, [-0.03, 0, 1]');
A = bsxfun(@minus, A, [-0.03, 0, 0]');

vector = [wx,wy,wz];

B = R * vector';
B = bsxfun(@minus, B, [0, 0, 0]');

vector = [r,p,y];

%C = R * vector';
C = R;
C = bsxfun(@minus, C, [0, 0, 0]');


mean(ax)
mean(ay)
mean(az)

%figure;plot(x, A(1, :), x, A(2, :), x, A(3, :))
%figure;plot(x, B(1, :), x, B(2, :), x, B(3, :))
figure;plot(x, C(1, :), x, C(2, :), x, C(3, :))
