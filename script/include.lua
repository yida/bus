local pwd = os.getenv('PWD')
local repopath = '/home/yida/Projects/UPennTHOR/Player'
package.path = repopath..'/Util/?.lua;'..package.path
package.cpath = repopath..'/Lib/?.so;'..package.cpath

package.cpath = pwd..'/luaGeographicLib/?.so;'..package.cpath


