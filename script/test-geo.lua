local pwd = os.getenv('PWD')
package.cpath = pwd..'/luaGeographicLib/?.so;'..package.cpath

local geo = require 'GeographicLib'

pos = geo.Forward(27.99, 86.93, 8820)
print(pos.x, pos.y, pos.z)

