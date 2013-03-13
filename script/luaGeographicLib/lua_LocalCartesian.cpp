extern "C" {
  #include "lua.h"
  #include "lualib.h"
  #include "lauxlib.h"
}

#include <exception>
#include <GeographicLib/LocalCartesian.hpp>


using namespace std;
using namespace GeographicLib;


static const struct luaL_reg LocalCartesian_Methods [] = {
  {NULL, NULL}
};

static const struct luaL_reg LocalCartesian_Functions [] = {
  {NULL, NULL}
};

extern "C" int luaopen_LocalCartesian(lua_State *L) {
  luaL_register(L, NULL, LocalCartesian_Methods);
  luaL_register(L, "LocalCartesian", LocalCartesian_Functions);
  return 1;
}

