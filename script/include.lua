local pwd = os.getenv('PWD')
local repopath = '../../UPennTHOR/'
package.cpath = repopath..'/Frameworks/Msgpack/?.so;'..package.cpath
package.cpath = repopath..'/Modules/carray/?.so;'..package.cpath
package.cpath = repopath..'/Modules/cutil/?.so;'..package.cpath
package.cpath = repopath..'/Modules/unix/?.so;'..package.cpath
package.cpath = repopath..'/Modules/msgpack/?.so;'..package.cpath
package.path = repopath..'/Util/?.lua;'..package.path

local repopath = '../../UPennDev/'
package.cpath = repopath..'/Lib/Modules/Util/Unix/?.so;'..package.cpath


print(pwd)
package.cpath = pwd..'/lib/GeographicLib/?.so;'..package.cpath
package.cpath = pwd..'/lib/Serial/?.so;'..package.cpath
package.cpath = pwd..'/lib/LuaXml/?.so;'..package.cpath
package.path = pwd..'/lib/LuaXml/?.lua;'..package.path


