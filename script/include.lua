local pwd = os.getenv('PWD')
local repopath = '/Users/Yida/Projects/UPennTHOR/Player'
package.path = repopath..'/Util/?.lua;'..package.path
package.cpath = repopath..'/Lib/?.so;'..package.cpath

package.cpath = pwd..'/luaGeographicLib/?.so;'..package.cpath


