extern "C" {
  #include "lua.h"
  #include "lualib.h"
  #include "lauxlib.h"
}

#include "lua_Constants.hpp"
#include "lua_Geocentric.hpp"
#include "lua_LocalCartesian.hpp"

int lua_GeographicLib_index(lua_State *L) {
  // Get index through metatable:
  if (!lua_getmetatable(L, 1)) {lua_pop(L, 1); return 0;} // push metatable
  lua_pushvalue(L, 2); // copy key
  lua_rawget(L, -2); // get metatable function
  lua_remove(L, -2); // delete metatable
  return 1;
}

extern "C" int luaopen_GeographicLib (lua_State *L) {
  luaopen_Constants(L);
  luaopen_LocalCartesian(L);
  luaopen_Geocentric(L);
  return 1;
}


