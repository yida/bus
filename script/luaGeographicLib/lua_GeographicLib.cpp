#ifdef __cplusplus
extern "C" {
#endif

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#ifdef __cplusplus
}
#endif

#include "lua_Geocentric.h"


static const struct luaL_reg GeographicLib_lib [] = {
  {"Forward", lua_Geocentric_Forward},
  {NULL, NULL}
};

#ifdef __cplusplus
extern "C"
#endif
int luaopen_GeographicLib (lua_State *L) {
  luaL_register(L, "GeographicLib", GeographicLib_lib);

  return 1;
}

