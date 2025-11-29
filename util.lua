function pad_str(str, len)
  local padding = len - #str
  while padding > 0 do
    str = str .. " "
    padding -= 1
  end
  return str
end

function set_palette(color)
  for i = 0, 15 do
    pal(i, color)
  end
end

function spr_outline(id, x, y, flip_x)
  set_palette(0)
  for x = x - 1, x + 1 do
    for y = y - 1, y + 1 do
      spr(id, x, y, 1, 1, flip_x)
    end
  end
  pal()
  spr(id, x, y, 1, 1, flip_x)
end