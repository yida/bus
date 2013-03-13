require 'GeographicLib'

print(Constants.WGS84_a(), Constants.WGS84_f())
a = Geocentric.new(Constants.WGS84_a(), Constants.WGS84_f())
ret = a:Forward(27.99, 86.93, 8820)
print(ret.x, ret.y, ret.z)
ret = a:Reverse(ret.x, ret.y, ret.z)
print(ret.lat, ret.lon, ret.h)
print(a)

