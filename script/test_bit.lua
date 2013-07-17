require 'include'
local ffi = require 'ffi'
local bit = require 'bit'

a = 12
b = 422
c = 4
d = 90

print(ffi.new('int16_t', bit.bor(bit.lshift(60, 8), 215)) / 5000)
--e = bit.bor(bit.lshift(a, 24), bit.lshift(b, 16), bit.lshift(c, 8), d)
--print('228983898')
--
--require 'cutil'
--
--e = cutil.bit_or(cutil.bit_lshift(a, 24), cutil.bit_lshift(b, 16),
--              cutil.bit_lshift(c, 8), d)
--print(e)
