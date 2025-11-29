function pad_str(str, len)
  local padding = len - #str
  while padding > 0 do
    str = str .. " "
    padding -= 1
  end
  return str
end