screen_transition_dur = 0.5

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

function draw_screen_transition(draw_func1, draw_func2, elapsed)
  local camera_x, camera_y = global.camera_x, global.camera_y
  local progress = min(1, elapsed / screen_transition_dur)
  local reverse = progress > 0.5
  local progress = reverse and (progress - 0.5) * 2 or progress * 2
  local frontier = flr(progress * 32)
  local func = reverse and draw_func2 or draw_func1

  func()
  for x = 0, 32 do
    for y = 0, 32 do
      local i = x + y
      local ok = reverse and i > frontier or not reverse and i < frontier
      if ok then
        local x = camera_x + x * 8
        local y = camera_y + y * 8
        rectfill(x, y, x + 7, y + 7, 5)
      end
    end
  end
end