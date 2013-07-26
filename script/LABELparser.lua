function readLABELLine(str, len, labeloffset)
  local ts_len = len or 16;
  local label = {}
  label.type = 'label'
  label.timestamp = tonumber(str:sub(1, ts_len))
  label.value = str:sub(ts_len + 1, ts_len + 4)
  return label
end


