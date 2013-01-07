
timeStamp = 10;
dt = 1 / timeStamp;
u_s = 2.235; % m/s -> 5mph
u_phi = 0.424;% rad/s, with min turning radius 13.4
L = 6.05;

x = 0;
y = 0;
theta = 0;

hold on;
for i = 1 : 10 * timeStamp 
  theta = theta + u_s / L * tan(u_phi) * dt;
  x = x + u_s * cos(theta) * dt;
  y = y + u_s * sin(theta) * dt;
  plot(x, y, '*');
end

drawnow;
