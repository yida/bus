
local ffi = require'ffi'

require'Geocentric_h'

local C = ffi.load 'Geographic'

x = ffi.new('double')
y = ffi.new('double')
z = ffi.new('double')
ffi.C.Forward(27.99, 86.93, 8820, x, y, z)
print(x, y, z)
