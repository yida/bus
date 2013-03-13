function indentSpace(indent)
  local str = ''
  for i = 1, indent do
    str = str..'  '
  end
  return str
end



local className = "Constants"

local classFunction = {
'WGS84_a',
'WGS84_f'
}

local filePath = './'
-- Generate Header
local headFileName = 'lua_'..className..'.hpp'
headFileName = filePath..headFileName

local head = io.open(headFileName, 'w')
head:write('#ifndef __LUA'..className:upper()..'_H__\n')
head:write('#define __LUA'..className:upper()..'_H__\n')

for i = 1, #classFunction do
  head:write(indentSpace(1)..'static int '..
      'lua_'..className..'_'..classFunction[i]..
      '(lua_State *L);\n')
end

head:write('\n')
head:write(indentSpace(1)..'extern \"C\" int luaopen_'..className..
      '(lua_State *L);\n')


head:write('#endif\n')
head:close()

-- Geenrate Source
local metaFileName = 'lua_'..className..'.cpp'
metaFileName = filePath..metaFileName
local meta = io.open(metaFileName, 'w')
meta:write(
"extern \"C\" {\n"..
indentSpace(1).."#include \"lua.h\"\n"..
indentSpace(1).."#include \"lualib.h\"\n"..
indentSpace(1).."#include \"lauxlib.h\"\n"..
"}\n\n"..
"#include <exception>\n"..
"#include <GeographicLib/"..className..".hpp>\n"
)
meta:write('\n\n')
meta:write('using namespace GeographicLib;\n')
meta:write('\n\n')
for i = 1, #classFunction do
meta:write('static int lua_'..className..'_'..classFunction[i]..
            '(lua_State *L) {\n')
meta:write(indentSpace(1)..'return 1;\n')
meta:write('}\n\n')
end

meta:write('static const struct luaL_reg '..className..
            '_Functions [] = {\n')
for i = 1, #classFunction do
  meta:write(indentSpace(1)..'{\"'..classFunction[i]..
              '\", lua_'..className..'_'..classFunction[i]..'},\n')
end
meta:write(indentSpace(1)..'{NULL, NULL}\n')
meta:write('};\n\n')

meta:write('extern \"C\" int luaopen_'..className..
      '(lua_State *L) {\n')
meta:write(indentSpace(1)..'luaL_register(L, NULL, '..className..'_Functions);\n')
meta:write(indentSpace(1)..'return 1;\n')
meta:write('}\n\n')



meta:close()


