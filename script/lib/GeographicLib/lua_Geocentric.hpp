#ifndef __LUAGEOCENTRIC_H__
#define __LUAGEOCENTRIC_H__

#include <GeographicLib/Geocentric.hpp>

GeographicLib::Geocentric * lua_checkGeocentric(lua_State *L, int narg);
extern "C" int luaopen_Geocentric(lua_State *L);

#endif
