require 'include'

local ffi = require 'ffi'
local Z = require 'Z'

function matType(nType)
  local Type = ''
  if nType == 1 then
    Type = 'miINT8'
  elseif nType == 2 then
    Type = 'miUINT8'  
  elseif nType == 3 then
    Type = 'miINT16'
  elseif nType == 4 then
    Type = 'miUINT16'
  elseif nType == 5 then
    Type = 'miINT32'
  elseif nType == 6 then
    Type = 'miUINT32'
  elseif nType == 7 then
    Type = 'miSINGLE'
  elseif nType == 9 then
    Type = 'miDOUBLE'
  elseif nType == 12 then
    Type = 'miINT64'
  elseif nType == 13 then
    Type = 'miUINT64'
  elseif nType == 14 then
    Type = 'miMATRIX'
  elseif nType == 15 then
    Type = 'miCOMPRESSED'
  elseif nType == 16 then
    Type = 'miUTF8'
  elseif nType == 17 then
    Type = 'miUTF16'
  elseif nType == 18 then
    Type = 'miUTF32'
  end
  return Type
end

function matArrayType(nType)
  local Type = ''
  if nType == 1 then 
    Type = 'mxCELL_CLASS'
  elseif nType == 2 then
    Type = 'mxSTRUCT_CLASS'
  elseif nType == 3 then
    Type = 'mxOBJECT_CLASS'
  elseif nType == 4 then
    Type = 'mxCHAR_CLASS'
  elseif nType == 5 then
    Type = 'mxSPARSE_CLASS'
  elseif nType == 6 then
    Type = 'mxDOUBLE_CLASS'
  elseif nType == 7 then
    Type = 'mxSINGLE_CLASS'
  elseif nType == 8 then
    Type = 'mxINT8_CLASS'
  elseif nType == 9 then
    Type= 'mxUINT8_CLASS'
  elseif nType == 10 then
    Type = 'mxINT16_CLASS'
  elseif nType == 11 then
    Type = 'mxUINT16_CLASS'
  elseif nType == 12 then
    Type = 'mxINT32_CLASS'
  elseif nType == 13 then
    Type = 'mxUINT32_CLASS'
  end
  return Type
end

function parseTag(tag)
  local dataT = tonumber(ffi.new("uint32_t", 
              bit.bor(bit.lshift(tag:byte(4), 24), bit.lshift(tag:byte(3), 16), 
              bit.lshift(tag:byte(2), 8), tag:byte(1))))
  local datasize = tonumber(ffi.new("uint32_t", 
              bit.bor(bit.lshift(tag:byte(8), 24), bit.lshift(tag:byte(7), 16), 
              bit.lshift(tag:byte(6), 8), tag:byte(5))))
  return dataT, datasize
end

function load(filename)
  file = assert(io.open(filename, 'rb'))
  header = file:read(128)
  destext = header:sub(1, 116)
  print(destext)
  version = tonumber(ffi.new('int16_t',
                      bit.bor(bit.lshift(header:byte(126), 8), header:byte(125))))
  print('Version '..bit.tohex(version))
  endian = header:sub(127, 128)
  print('Endian '..endian)
  
  
  file:seek('set', 128)
  Tag = file:read(8)
  
  dataT, nbyte = parseTag(Tag)
  
  
  file:seek('set', 136)
  data = file:read(nbyte)
  if dataT == 15 then
    realdata = Z.uncompress(data, nbyte) 
    dataT, nbyte = parseTag(realdata:sub(1, 8))
--    print(matType(dataT))
--    print(nbyte)
    data = realdata
  end

  if dataT == 14 then
    data = data:sub(9, #data)
    ArrayflagsTagByte = data:sub(1, 8)
    ArrayflagsT, ArrayflagN = parseTag(ArrayflagsTagByte)
    ArrayflagsBodyByte = data:sub(9, 9 + ArrayflagN)
    ArrayClass = ArrayflagsBodyByte:byte(1)
    Arrayflags = ArrayflagsBodyByte:byte(2)
    logical = bit.rshift(bit.band(Arrayflags, 0x00000002), 1)
    print('logical '..logical)
    global = bit.rshift(bit.band(Arrayflags, 0x00000004), 2)
    print('global '..global)
    complex = bit.rshift(bit.band(Arrayflags, 0x00000008), 3)
    print('complex '..complex)
  
    DimensionsTagByte = data:sub(17, 32)

--    print(DimensionsByte:byte(1, 8))
--    print(DimensionsByte:byte(9, 16))

--    ArrayNameByte = data:sub(1, 16)
  end
  
  --print(matType(dataT))
  --print(realdata:byte(1, 8))
  --print(realdata:byte(9, 16))
  
  file:close()
end

--filename = 'curData.mat'
--filename = 'aa.mat'
filename = 'bb.mat'
load(filename)