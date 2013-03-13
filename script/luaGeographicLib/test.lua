require 'GeographicLib'

print(Constants.WGS84_a(), Constants.WGS84_f())
a = Geocentric.new(Constants.WGS84_a(), Constants.WGS84_f())
a:Forward()
print(a)

