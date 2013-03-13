extern "C" {
  #include "lua.h"
  #include "lualib.h"
  #include "lauxlib.h"
}

#include "lua_Geocentric.hpp"
#include "lua_LocalCartesian.hpp"

extern "C" int luaopen_GeographicLib (lua_State *L) {
  luaopen_LocalCartesian(L);
  luaopen_Geocentric(L);
  return 1;
}


