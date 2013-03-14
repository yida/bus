#ifndef __LUALOCALCARTESIAN_H__
#define __LUALOCALCARTESIAN_H__

#include <GeographicLib/LocalCartesian.hpp>

  GeographicLib::LocalCartesian * lua_checkLocalCartesian(lua_State *L, int narg);
  extern "C" int luaopen_LocalCartesian(lua_State *L);
#endif
