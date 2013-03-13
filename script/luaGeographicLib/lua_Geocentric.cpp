extern "C" {
  #include "lua.h"
  #include "lualib.h"
  #include "lauxlib.h"
}

#include <iostream>
#include <exception>
#include <GeographicLib/Geocentric.hpp>


using namespace std;
using namespace GeographicLib;


static int lua_Geocentric_new(lua_State *L) {
  double a = luaL_checknumber(L, 1);
  double f = luaL_checknumber(L, 2);
  Geocentric *earth = (Geocentric *)lua_newuserdata(L, sizeof(Geocentric)); 
  try {
  }
  catch (exception& e) {
    luaL_error(L, "Caught exception");
  }
  luaL_getmetatable(L, "Geocentric_mt");
  lua_setmetatable(L, -2);

  return 1;
}

static int lua_Geocentric_Forward(lua_State *L) {
  try {
    cout << "Forward" << endl;
  }
  catch (exception& e) {
    luaL_error(L, "Caught exception");
  }
  return 1;
}

static int lua_Geocentric_Reverse(lua_State *L) {
  try {
    cout << "Reverse" << endl;
  }
  catch (exception& e) {
    luaL_error(L, "Caught exception");
  }
  return 1;
}

static int lua_Geocentric_index(lua_State *L) {
  // Get index through metatable:
  if (!lua_getmetatable(L, 1)) {lua_pop(L, 1); return 0;} // push metatable
  lua_pushvalue(L, 2); // copy key
  lua_rawget(L, -2); // get metatable function
  lua_remove(L, -2); // delete metatable
  return 1;
}

static const struct luaL_reg Geocentric_Methods [] = {
  {"Forward", lua_Geocentric_Forward},
  {"Reverse", lua_Geocentric_Reverse},
  {NULL, NULL}
};

static const struct luaL_reg Geocentric_Functions [] = {
  {"new", lua_Geocentric_new},
  {NULL, NULL}
};

extern "C" int luaopen_Geocentric(lua_State *L) {
  luaL_newmetatable(L, "Geocentric_mt");

  // Implement index method:
  lua_pushstring(L, "__index");
  lua_pushcfunction(L, lua_Geocentric_index);
  lua_settable(L, -3);

  luaL_register(L, NULL, Geocentric_Methods);
  luaL_register(L, "Geocentric", Geocentric_Functions);
  return 1;
}

