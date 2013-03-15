require 'include'
require 'common'

local util = require 'util'

local mp = require'luajit-msgpack-pure'
--local mp = require'MessagePack'

tbl = {['a'] = 45, ['rt']='4444'}
tbl1 = {['b'] = 45, ['t']='4444'}

str = mp.pack(tbl)
str1 = mp.pack(tbl1)
st = str..str1
offset, decoded = mp.unpack(st)
print(offset, decoded)
util.ptable(decoded)
offset1, decoded = mp.unpack(st, offset)
print(offset1, decoded)
util.ptable(decoded)


--print(str)
--print(str1)
--print(#str, #str1, #st)
--t = mp.unpacker(str..str1)
--for k, v in mp.unpacker(t) do
--  print(k, v)
--end

--print(str:byte(1, #str))
--print(str1:byte(1, #str1))
--st = str..str1
--print(st)
--print(st:byte(1, #st))
----b = mp.unpack(str..str1)
--util.ptable(t)
--util.ptable(b)
