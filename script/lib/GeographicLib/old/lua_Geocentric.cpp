#ifdef __cplusplus
extern "C" {
#endif

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#ifdef __cplusplus
}
#endif

#include "lua_Geocentric.hpp"

#include <iostream>
#include <exception>
#include <GeographicLib/Geocentric.hpp>

using namespace GeographicLib;

static int lua_Geocentric_Forward(lua_State *L) {
  double lat = luaL_checknumber(L, 1);
  double lon = luaL_checknumber(L, 2);
  double h = luaL_checknumber(L, 3);
  try {
    Geocentric earch(Constants::WGS84_a(), Constants::WGS84_f());
    double x, y, z;
    earch.Forward(lat, lon, h, x, y, z);
    lua_createtable(L, 0, 1);
    lua_pushstring(L, "x");
    lua_pushinteger(L, x);
    lua_settable(L, -3);

    lua_pushstring(L, "y");
    lua_pushinteger(L, y);
    lua_settable(L, -3);

    lua_pushstring(L, "z");
    lua_pushinteger(L, z);
    lua_settable(L, -3);

    return 1;
  } catch (const std::exception& e) {
    std::cerr << "Caught exception: " << e.what() << "\n";
    return 1;
  }
}

static int lua_Geocentric_Reverse(lua_State *L) {
  return 1;
}


static const struct luaL_reg Geocentric_lib [] = {
  {"Forward", lua_Geocentric_Forward},
  {"Reverse", lua_Geocentric_Reverse},
  {NULL, NULL}
};

extern "C" int luaopen_Geocentric(lua_State *L) {
  luaL_register(L, "Geocentric", Geocentric_lib);
  return 1;
}

