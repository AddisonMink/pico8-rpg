function world_new()
  -- #region constants
  local side_frames = { 72, 73 }
  local down_frames = { 88, 89, 88, 90 }
  local up_frames = { 75, 76, 75, 77 }
  -- #endregion

  -- #region state
  local x, y = 64, 64
  local moving = false
  local frames = side_frames
  local flip_x = false
  local id = frames[1]
  local me = {}
  -- #endregion

  local function tile_pos(x, y)
    return flr((x + 4) / 8), flr((y + 4) / 8)
  end

  local function move()
    local dx = btn(0) and -1 or btn(1) and 1 or 0
    local dy = dx == 0 and (btn(2) and -1 or btn(3) and 1 or 0) or 0
    local tx, ty = tile_pos(x + dx, y + dy)
    local tile_id = mget(tx, ty)
    local in_bounds = tx >= 0 and tx < 16 and ty > 2 and ty < 16

    if not in_bounds then
      dx, dy = 0, 0
    end

    moving = dx != 0 or dy != 0
    x += dx
    y += dy
    if dx ~= 0 then
      frames, flip_x = side_frames, dx > 0
    elseif dy > 0 then
      frames, flip_x = down_frames, false
    elseif dy < 0 then
      frames, flip_x = up_frames, false
    end

    id = moving and frames[flr(time() * 6) % #frames + 1] or frames[1]
    return tx, ty, tile_id
  end

  function me:update()
    local tx, ty, tile_id = move()
  end

  function me:draw()
    cls(3)
    rectfill(0, 0, 127, 7, 0)
    rectfill(0, 8, 127, 27, 12)
    map()
    spr_outline(id, x, y, flip_x)
  end

  return me
end