function BUS = busUpdate(bus, dt)

  % rare centered motion update
  bus.ktheta = bus.ktheta + bus.u_s / bus.L * tan(bus.u_phi) * dt;
  bus.kx = bus.kx + bus.u_s * cos(bus.ktheta) * dt;
  bus.ky = bus.ky + bus.u_s * sin(bus.ktheta) * dt;

  % map motion update to bus center
  bus.theta = bus.ktheta - pi/2;
  bus.cx = bus.kx + (bus.h/2 - bus.rw) * cos(bus.ktheta);
  bus.cy = bus.ky + (bus.h/2 - bus.rw) * sin(bus.ktheta);


  if (bus.cy > -9)
    bus.u_phi = 0.424;
  end

  if abs(bus.theta - pi /2 ) < 0.01
    bus.u_phi = 0;
  end

  BUS = bus;
