#ifndef __LUA_LOCALCARTESIAN_H__
#define __LUA_LOCALCARTESIAN_H__

static int lua_LocalCartesian_Forward(lua_State *L);
static int lua_LocalCartesian_Reverse(lua_State *L);

extern "C" int luaopen_LocalCartesian(lua_State *L);

#endif
