local ucm = require 'ucm'

for k, v in pairs(ucm) do
  print(k, v)
end

tbl = getfenv()
--for k, v in pairs(tbl) do
--  print(k, v)
--end
