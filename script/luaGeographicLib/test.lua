require 'GeographicLib'

ret = Geocentric.Forward(27.99, 86.93, 8820)
print(ret.x, ret.y, ret.z)

