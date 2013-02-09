
local ffi = require 'ffi'

ffi.cdef[[
  typedef double real;
  void Forward (real lat, real lon, real h, real &X, real &Y, real &Z);
  void  Reverse (real X, real Y, real Z, real &lat, real &lon, real &h);
]]
