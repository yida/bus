
-- welcome message
print 'Torch 7.0  Copyright (C) 2001-2011 Idiap, NEC Labs, NYU'

-- custom prompt
_PROMPT  = 't7> '
_PROMPT2 = '. > '

-- helper
local function sizestr(x)
   local strt = {}
   if _G.torch.typename(x):find('torch.*Storage') then
      return _G.torch.typename(x):match('torch%.(.+)') .. ' - size: ' .. x:size()
   end
   if x:nDimension() == 0 then
      table.insert(strt, _G.torch.typename(x):match('torch%.(.+)') .. ' - empty')
   else
      table.insert(strt, _G.torch.typename(x):match('torch%.(.+)') .. ' - size: ')
      for i=1,x:nDimension() do
         table.insert(strt, x:size(i))
         if i ~= x:nDimension() then
            table.insert(strt, 'x')
         end
      end
   end
   return table.concat(strt)
end

-- k : name of variable
-- m : max length
local function printvar(key,val,m)
   local name = '[' .. tostring(key) .. ']'
   --io.write(name)
   name = name .. string.rep(' ',m-name:len()+2)
   local tp = type(val)
   if tp == 'userdata' then
      tp = torch.typename(val) or ''
      if tp:find('torch.*Tensor') then
         tp = sizestr(val)
      elseif tp:find('torch.*Storage') then
         tp = sizestr(val)
      else
         tp = tostring(val)
      end
   elseif tp == 'table' then
      tp = tp .. ' - size: ' .. #val
   elseif tp == 'string' then
      local tostr = val:gsub('\n','\\n')
      if #tostr>40 then
         tostr = tostr:sub(1,40) .. '...'
      end
      tp = tp .. ' : "' .. tostr .. '"'
   else
      tp = tostring(val)
   end
   return name .. ' = ' .. tp
end

-- helper
local function getmaxlen(vars)
   local m = 0
   if type(vars) ~= 'table' then return tostring(vars):len() end
   for k,v in pairs(vars) do
      local s = tostring(k)
      if s:len() > m then
         m = s:len()
      end
   end
   return m
end

-- who:
-- a simple function that prints all the symbols defined by the user
-- very much like Matlab's who function
function who()
   local m = getmaxlen(_G)
   local p = _G._preloaded_
   local function printsymb(sys)
      for k,v in pairs(_G) do
         if (sys and p[k]) or (not sys and not p[k]) then
       print(printvar(k,_G[k],m))
         end
      end
   end
   print('== System Variables ==')
   printsymb(true)
   print('== User Variables ==')
   printsymb(false)
   print('==')
end

-- exit:
-- a simple function to exit Torch :-)
function exit()
   os.exit()
end

print_old=print
_G._preloaded_ = {}
for k,v in pairs(_G) do
   _G._preloaded_[k] = true
end

-- print:
-- a smarter print for Lua, the default Lua print is quite terse
-- this new print is much more verbose, automatically recursing through
-- lua tables, and objects.
local print_new
function print(...)
   if select('#',...) == 0 then
      _G.io.write('\n')
      _G.io.flush()
      return
   end
   local obj = ...
   if _G.type(obj) == 'table' then
      local mt = _G.getmetatable(obj)
      if mt and mt.__tostring__ then
         _G.io.write(mt.__tostring__(obj))
      else
         local m = getmaxlen(obj)
         local tos = _G.tostring(obj)
         local obj_w_usage = false
         if tos and not _G.string.find(tos,'table: ') then
            if obj.usage and _G.type(obj.usage) == 'string' then
               _G.io.write(obj.usage)
               _G.io.write('\n\nFIELDS:\n')
               obj_w_usage = true
            else
               _G.io.write(tos .. ':\n')
            end
         end
         _G.io.write('{')
         local idx = 1
    local tab = ''
    local newline = ''
         for k,v in pairs(obj) do
       local line = printvar(k,v,m)
       _G.io.write(newline .. tab .. line)
       if idx == 1 then
          tab = ' '
          newline = '\n'
       end
       idx = idx + 1
         end
         _G.io.write('}')
         if obj_w_usage then
            _G.io.write('')
         end
      end
   else
      _G.io.write(_G.tostring(obj))
   end
   if _G.select('#',...) > 1 then
      _G.io.write('    ')
      print_new(select(2,...))
   else
      _G.io.write('\n')
   end
end
print_new = print

-- printr:
-- recursive print. This function prints tables recursively. It could 
-- be merged into the regular print() above, but might be too dangerous
-- when printing large tables?
function printr(obj)
   local function printrecursive(obj,tab)
      local tab = tab or 0
      local line = function(s) for i=1,tab do io.write(' ') end print(s) end
      line('{')
      tab = tab+2
      for k,v in pairs(obj) do
         if type(v) == 'table' then
            line(k .. ' : ') printrecursive(v,tab+4)
         else
            line(k .. ' : ' .. tostring(v))
         end
      end
      tab = tab-2
      line('}')
   end
   if type(obj) ~= 'table' then print(obj)
   else printrecursive(obj) end
end

-- table():
-- ok, this is slightly out of context, but that function
-- should really exist in Lua. It creates a new table, and then
-- imports all the table methods into it, so that you can do things
-- like:
-- t = table()
-- t:insert(1)
-- t:insert(2)
-- print(t)
-- > {1,2}
local function newtable()
   local t = {}
   for k,v in pairs(table) do
      t[k] = v
   end
   return t
end
setmetatable(table, {__call=newtable})

-- import:
-- this function is a python-like loader, it requires a module,
-- and then imports all its symbols globally
function import(package, forced)
   require(package)
   if _G[package] then
      _G._torchimport = _G._torchimport or {}
      _G._torchimport[package] = _G[package]
   end
   for k,v in pairs(_G[package]) do
      if not _G[k] or forced then
         _G[k] = v
      end
   end
end

-- install module:
-- this function builds and install a specified module
function install(path)
   path = paths.concat(paths.cwd(), path)
   print('--> installing module ' .. path)
   os.execute('mkdir ' .. paths.concat(path,'build') .. '; '
           .. 'cd ' .. paths.concat(path,'build') .. '; '
        .. 'cmake .. -DCMAKE_INSTALL_PREFIX=' .. paths.install_prefix .. '; '
        .. 'make install; cd .. ; rm -r build')
   print('--> module installed')
end

function loaddefaultlibs(loadwithimport)
   if loadwithimport == nil then loadwithimport = false end
   if not loadwithimport then
      -- preload basic libraries
      require 'torch'
      require 'gnuplot'
--      require 'dok'
   else
      import 'torch'
      import 'gnuplot'
--      import 'dok'
   end
end

loaddefaultlibs(loadwithimport)

-- setup local paths
--local localinstalldir = paths.concat(os.getenv('HOME'),'.torch','usr')
--if paths.dirp(localinstalldir) then
--   package.path = paths.concat(localinstalldir,'share','torch','lua','?','init.lua') .. ';' .. package.path
--   package.path = paths.concat(localinstalldir,'share','torch','lua','?.lua') .. ';' ..  package.path
--   package.cpath = paths.concat(localinstalldir,'lib','torch','?.so') .. ';' .. package.cpath
--   package.cpath = paths.concat(localinstalldir,'lib','torch','?.dylib') .. ';' .. package.cpath
--end
