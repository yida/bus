#ifndef __LUACONSTANTS_H__
#define __LUACONSTANTS_H__
  static int lua_Constants_WGS84_a(lua_State *L);
  static int lua_Constants_WGS84_f(lua_State *L);

  extern "C" int luaopen_Constants(lua_State *L);
#endif
