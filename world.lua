function world_new()
  -- #region constants
  local side_frames = { 16, 17 }
  local down_frames = { 22, 23, 22, 24 }
  local up_frames = { 6, 7, 6, 8 }
  -- #endregion

  -- #region state
  local x, y = 13 * 8, 15 * 8
  local camera_x, camera_y = x - 32, y - 32
  local moving = false
  local frames = side_frames
  local flip_x = false
  local id = frames[1]
  local steps = 0
  local on_scripted_battle_tile = false
  local dialogue = nil
  local me = {}
  -- #endregion

  local dialogue_map = {
    ["14,15"] = dialogue_town_shop,
    ["17,14"] = dialogue_town_inn,
    ["8,8"] = dialogue_wizard_tower
  }

  local function tile_pos(x, y)
    return flr((x + 4) / 8), flr((y + 4) / 8)
  end

  local function move()
    local dx = btn(0) and -1 or btn(1) and 1 or 0
    local dy = dx == 0 and (btn(2) and -1 or btn(3) and 1 or 0) or 0
    local tx, ty = tile_pos(x + dx, y + dy)
    local tile_id = mget(tx, ty)
    local in_bounds = tx >= 0 and tx < 31 and ty > 2 and ty < 31
    local blocking = fget(tile_id, 0)

    if blocking or not in_bounds then
      dx, dy = 0, 0
    end

    moving = dx != 0 or dy != 0
    steps += moving and 1 or 0
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

    if (x - camera_x) < 32 then
      camera_x = max(0, camera_x - 1)
    elseif camera_x + 120 - x < 32 then
      camera_x = min(128, camera_x + 1)
    end
    if (y - camera_y) < 32 then
      camera_y = max(0, camera_y - 1)
    elseif camera_y + 120 - y < 32 then
      camera_y = min(128, camera_y + 1)
    end

    return tx, ty, tile_id
  end

  function me:update()
    camera(camera_x, camera_y)
    local tx, ty, tile_id = move()
    local key = tx .. "," .. ty
    dialogue = dialogue_map[key]

    if dialogue and btnp(4) then
      return "dialogue", dialogue
    end
  end

  function me:draw()
    cls(3)
    rectfill(0, 0, 256, 7, 0)
    rectfill(0, 8, 256, 27, 12)
    map()
    spr_outline(id, x, y, flip_x)

    if dialogue then
      local prompt = "\142 to enter"
      local x = x - #prompt * 2 + 4
      local y = y - 10
      print(prompt, x, y, 7)
    end
  end

  return me
end