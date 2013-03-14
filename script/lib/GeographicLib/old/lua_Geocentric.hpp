#ifndef __LUA_GEOCENTRIC_H__
#define __LUA_GEOCENTRIC_H__

static int lua_Geocentric_Forward(lua_State *L);
static int lua_Geocentric_Reverse(lua_State *L);

extern "C" int luaopen_Geocentric(lua_State *L);

#endif
