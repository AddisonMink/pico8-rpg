function battle_new()
  -- #region constants
  local animation_fps = 12
  local attack_id_offsets = { 2, 4, 7 }
  local attack_widths = { 2, 3, 3 }
  local attack_offests = { 0, -8, -8 }
  local slash_id = 166
  local starting_dur = 0.75
  local camera_x, camera_y = peek2(0x5f28), peek2(0x5f2a)
  -- #endregion

  local player = global.player
  local enemy = goblin_new()
  local action_menu = action_menu_new()
  local effects = {}
  local acting = nil
  local flash, anim, message, t0 = nil, nil, nil, time()
  local state = "player_turn"
  local me = {}

  local function draw_message(text, color)
    local x = camera_x + 64 - (#text * 2)
    local y = camera_y + 64 - 2
    print(text, x, y, color)
  end

  local function draw_unit(unit, x, y)
    if unit.state == "dead" then return end
    local tint = flash and flash.target == unit and flash.color
    local anim_id = anim and anim.target == unit and anim.id
    local message = message and message.target == unit and message.text

    if tint then
      set_palette(tint)
    end
    if unit.player and unit.state == "attack" then
      local frame = min(flr((time() - unit.t0) * animation_fps), 2) + 1
      local id = unit.sprite_id + attack_id_offsets[frame]
      local w = attack_widths[frame]
      local x = x + attack_offests[frame]
      spr(id, x, y, w, 2)
    else
      spr(unit.sprite_id, x, y, 2, 2)
    end
    pal()

    if anim_id then
      local frame = min(flr((time() - t0) * animation_fps), 2)
      local id = anim_id + frame * 2
      spr(id, x, y, 2, 2)
    end

    if message then
      local x = x + 8 - (#message * 2)
      print(message, x, y - 8, 7)
    end

    if unit.sleep then
      spr(109, x + 16, y)
      for i = 1, unit.sleep do
        local x = x + 24 + i * 2
        rectfill(x, y, x, y, 7)
      end
    end

    local x, y = x, y + 21
    rectfill(x - 1, y - 2, x + 21, y + 2, 0)
    for i = 1, ceil(unit.hp / 10) do
      rectfill(x, y, x, y, 8)
      x += 2
    end
  end

  local effect_handlers = {
    attack = function(effect)
      local target = effect.target
      add(effects, { t = "animation", target = target, id = slash_id }, 1)
      add(effects, { t = "damage", target = target, power = 10 }, 2)
    end,
    damage = function(effect)
      local target = effect.target
      local damage = effect.power
      if target.armor and not effect.magic then damage = flr(damage / 2) end
      target.hp -= damage
      target.sleep = nil
      add(effects, { t = "flash", target = target, color = 8 }, 1)
      if target.hp <= 0 then
        add(effects, { t = "flash", target = target, color = 1, dur = 0.5 }, 2)
        add(effects, { t = "death", target = target }, 3)
      end
    end,
    flash = function(effect)
      dur = effect.dur or 0.2
      t0 = time()
      flash = { target = effect.target, color = effect.color }
    end,
    animation = function(effect)
      dur = 0.3
      t0 = time()
      anim = { target = effect.target, id = effect.id }
    end,
    message = function(effect)
      message = { target = effect.target, text = effect.text }
      dur = 0.5
      t0 = time()
    end,
    death = function(effect)
      effect.target.state = "dead"
    end,
    heal = function(effect)
      local target = effect.target
      target.hp = min(target.hp + 30, target.max_hp)
      add(effects, { t = "flash", target = target, color = 11 })
    end,
    sleep = function(effect)
      effect.target.sleep = 3
    end
  }

  function me:update()
    if state == "player_turn" then
      local result = action_menu:update()
      if not result then return end
      if result == "attack" then
        player.state = "attack"
        player.t0 = time()
        effects = { { t = "attack", target = enemy } }
        acting = player
        t0, dur = time(), 0.3
        state = "exec"
      elseif result == "escape" then
      elseif result.type == "item" then
      elseif result.type == "spell" then
      end
    elseif state == "enemy_turn" then
      local behavior = enemy.behavior(enemy, player)
      effects = behavior.effects
      add(effects, { t = "message", target = enemy, text = behavior.name }, 1)
      dur, t0 = 0, time()
      acting = enemy
      state = "exec"
    elseif state == "exec" then
      local done = time() - t0 > dur
      if not done then return end
      flash, anim, message = nil, nil, nil
      if #effects > 0 then
        local effect = deli(effects, 1)
        effect_handlers[effect.t](effect)
      else
        state = "end_turn"
      end
    elseif state == "end_turn" then
      player.state = "idle"

      if player.hp <= 0 then
        state = "lose"
      elseif enemy.hp <= 0 then
        state = "win"
      elseif acting == player then
        state = "enemy_turn"
      elseif acting == enemy then
        state = "player_turn"
      end
    elseif state == "win" and btnp(4) then
      return { t = "win", coins = enemy.coins }
    elseif state == "lose" and btnp(4) then
      return { t = "lose" }
    end
  end

  function me:draw()
    cls()

    draw_unit(enemy, camera_x + 32, camera_y + 32)
    draw_unit(player, camera_x + 72, camera_y + 32)

    if state == "player_turn" then
      action_menu:draw()
    elseif state == "win" then
      draw_message("v i c t o r y", 7)
    elseif state == "lose" then
      draw_message("d e f e a t", 8)
    end
  end

  return me
end