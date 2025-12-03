function game_new()
  local world = world_new()
  local battle, dialogue = nil
  local draw_trans_func1 = function() end
  local draw_trans_func2 = function() world:draw() end
  local next_state = "world"
  local t0 = time()
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

  function me:update()
    if state == "world" then
      local code, result = world:update()
      if code == "dialogue" then
        dialogue = result
        transition(world, dialogue, "dialogue")
      elseif code == "battle" then
        battle = battle_new(global.player, result)
        transition(world, battle, "battle")
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