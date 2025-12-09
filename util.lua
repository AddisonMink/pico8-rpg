screen_transition_dur = 0.5

function copy_table(t)
  local t2 = {}
  for k, v in pairs(t) do
    t2[k] = v
  end
  return t2
end

function table_values(t)
  local values = {}
  for _, v in pairs(t) do
    add(values, v)
  end
  return values
end

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

function set_palette(color)
  pal()
  for i = 0, 15 do
    pal(i, color)
  end
end

function draw_screen_transition(draw_func1, draw_func2, elapsed)
  local camera_x, camera_y = peek2(0x5f28), peek2(0x5f2a)
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

-- draw npatch panel
function draw_panel(x, y, w, h)
  spr(2, x, y)
  spr(3, x + w - 8, y)
  spr(18, x, y + h - 8)
  spr(19, x + w - 8, y + h - 8)
  sspr(20, 0, 8, 8, x + 8, y, w - 16, 8)
  sspr(16, 4, 8, 8, x, y + 8, 8, h - 16)
  sspr(20, 8, 8, 8, x + 8, y + h - 8, w - 16, 8)
  sspr(24, 4, 8, 8, x + w - 8, y + 8, 8, h - 16)
  rectfill(x + 8, y + 8, x + w - 9, y + h - 9, 1)
end

function draw_npc_sprite(id)
  local camera_x = peek2(0x5f28)
  local camera_y = peek2(0x5f2a)
  spr(id, camera_x + 32, camera_y + 16, 2, 2)
  spr(global.player.sprite_id, camera_x + 82, camera_y + 16, 2, 2)
end