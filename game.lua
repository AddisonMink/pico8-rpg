function game_new()
  local battle, dialogue = nil
  local draw_trans_func1 = function() end
  local draw_trans_func2 = function() world:draw() end
  local next_state = "world"
  local t0 = time()
  local scripted_battle_key = nil
  local scripted_battle_func = nil
  local state = "transition"
  local me = {}

  local function transition(from, to, next)
    draw_trans_func1 = function() from:draw() end
    draw_trans_func2 = function() to:draw() end
    next_state = state
    t0 = time()
    next_state = next
    state = "transition"
  end

  local function respawn()
    world:reset_position()
    global.player.max_hp = saved.player.max_hp
    global.player.max_mp = saved.player.max_mp
    global.coins = saved.coins
    global.spells = saved.spells
    global.items = {}
    global.player.hp = global.player.max_hp
    global.player.mp = global.player.max_mp

    -- reload map
    global.tile_changes = saved.tile_changes

    reload(0x2000, 0x2000, 0x1000)
    for tile_change in all(saved.tile_changes) do
      mset(tile_change.x, tile_change.y, tile_change.tile_id)
    end

    transition(battle, world, "world")
  end

  function me:update()
    if state == "world" then
      local code, result = world:update()
      if code == "dialogue" then
        dialogue = result
        transition(world, dialogue, "dialogue")
      elseif code == "battle" then
        battle = battle_new(result.enemy, result.background_id)
        transition(world, battle, "battle")
      elseif code == "scripted_battle" then
        battle = battle_new(result.spawn())
        scripted_battle_key = result.key
        scripted_battle_func = result.func
        transition(world, battle, "scripted_battle")
      elseif btnp(4) then
        dialogue = status_menu_new()
        transition(world, dialogue, "dialogue")
      end
    elseif state == "dialogue" then
      local done = dialogue:update()
      if done then
        transition(dialogue, world, "world")
      end
    elseif state == "battle" then
      local code, result = battle:update()
      if code == "win" then
        global.coins += result
        transition(battle, world, "world")
      elseif code == "lose" then
        respawn()
      elseif code == "escape" then
        transition(battle, world, "world")
      end
    elseif state == "scripted_battle" then
      local code, result = battle:update()
      if code == "win" then
        global.coins += result
        world:remove_scripted_battle_tile(scripted_battle_key)
        if scripted_battle_func then scripted_battle_func() end
        transition(battle, world, "world")
      elseif code == "lose" then
        respawn()
      elseif code == "escape" then
        transition(battle, world, "world")
      end
    elseif state == "transition" then
      local done = time() - t0 > screen_transition_dur
      if done then
        state = next_state
      end
    end
  end

  function me:draw()
    cls()
    if state == "world" then
      world:draw()
    elseif state == "dialogue" then
      dialogue:draw()
    elseif state == "battle" then
      battle:draw()
    elseif state == "scripted_battle" then
      battle:draw()
    elseif state == "transition" then
      draw_screen_transition(draw_trans_func1, draw_trans_func2, time() - t0)
    end

    -- draw hud
    local camera_x, camera_y = peek2(0x5f28), peek2(0x5f2a)
    local hp_str = "hp " .. global.player.hp .. "/" .. global.player.max_hp
    local hp_x = 4
    local mp_str = "mp " .. global.player.mp .. "/" .. global.player.max_mp
    local mp_x = 64 - (#mp_str * 4) / 2
    local coin_str = "$" .. global.coins
    local coin_x = 128 - (#coin_str * 4) - 2
    rectfill(camera_x, camera_y, camera_x + 128, camera_y + 8, 0)
    print(hp_str, camera_x + hp_x, camera_y + 2, 8)
    print(mp_str, camera_x + mp_x, camera_y + 2, 12)
    print(coin_str, camera_x + coin_x, camera_y + 2, 10)
  end

  return me
end