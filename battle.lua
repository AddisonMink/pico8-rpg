function battle_new(enemy, background_id)
  -- #region constants
  background_id = background_id or 172
  local animation_fps = 12
  local attack_id_offsets = { 2, 4, 7 }
  local attack_widths = { 2, 3, 3 }
  local attack_offests = { 0, -8, -8 }
  local slash_id = 166
  local starting_dur = 0.75
  local camera_x, camera_y = peek2(0x5f28), peek2(0x5f2a)
  -- #endregion

  -- #region state
  local player = global.player
  player.state = "idle"
  local action_menu = action_menu_new()
  local effects = {}
  local acting = nil
  local flash, anim, message, t0 = nil, nil, nil, time()
  local state = "player_turn"
  local me = {}
  -- #endregion

  local function draw_background()
    for x = 0, 8 do
      local x = camera_x + x * 16
      spr(background_id, x, camera_y + 8, 2, 2)
    end
  end

  local function draw_message(text, color)
    local x = camera_x + 64 - (#text * 2)
    local y = camera_y + 64 - 2
    print(text, x, y, color)
  end

  local function draw_status(x, y, id, duration)
    spr(id, x, y)
    y += 9
    for i = 1, min(duration, 4) do
      local x = x + (i - 1) * 2
      rectfill(x, y, x, y, 7)
    end
    y += 2
    for i = 1, duration - 4 do
      local x = x + (i - 1) * 2
      rectfill(x, y, x, y, 7)
    end
  end

  local function draw_unit(unit, x, y)
    if unit.state == "dead" then return end
    local anim_id = anim and anim.target == unit and anim.id
    local message = message and message.target == unit and message.text

    local tint = flash and flash.target == unit and flash.color
        or unit.invisible and 1

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
      spr(142, x + 16, y)
    end

    -- hp bar
    local hp_x, y = x, y + 21
    rectfill(hp_x - 1, y - 2, hp_x + 21, y + 2, 0)
    for i = 1, ceil(unit.hp / 10) do
      rectfill(hp_x, y, hp_x, y, 8)
      hp_x += 2
    end

    -- status icons
    local statuses = {}
    if unit.armor then add(statuses, { 143, unit.armor }) end
    if unit.sleep then add(statuses, { 142, unit.sleep }) end
    if unit.invisible then add(statuses, { 158, unit.invisible }) end
    local status_width = #statuses * 10 - 2
    local x = x + 8 - flr(status_width / 2)
    for status in all(statuses) do
      local id, duration = status[1], status[2]
      draw_status(x, y + 4, id, duration)
      x += 10
    end
  end

  local function compile_effects(effs, range)
    local target = range == "self" and player or enemy
    local compiled = {}
    for effect in all(effs) do
      local e = copy_table(effect)
      e.target = target
      add(compiled, e)
    end
    return compiled
  end

  local function dec_status(target)
    local statuses = { "armor", "sleep", "invisible" }
    for status in all(statuses) do
      if target[status] then
        target[status] -= 1
        if target[status] <= 0 then
          target[status] = nil
        end
      end
    end
  end

  local effect_handlers = {
    attack = function(effect)
      local target = effect.target
      local power = effect.power or 10
      add(effects, { t = "animation", target = target, id = slash_id }, 1)
      add(effects, { t = "damage", target = target, power = power }, 2)
    end,
    damage = function(effect)
      local target = effect.target

      if target.invisible then
        add(effects, { t = "message", target = target, text = "miss" })
        return
      end

      local damage = effect.power

      local damage = effect.magic and damage
          or target.armor and flr(damage / 2)
          or damage

      target.hp = max(0, target.hp - damage)
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
    end,
    invisible = function(effect)
      effect.target.invisible = 2
    end,
    dispel = function(effect)
      local target = effect.target
      target.armor = nil
      target.invisible = nil
      target.sleep = nil
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
        state = "escape"
      elseif result.type == "item" then
        local item_with_quant = result.item
        local item = item_with_quant.item
        local compiled = compile_effects(item.effects, item.range)
        item_with_quant.quantity -= 1
        if item_with_quant.quantity <= 0 then
          global.items[item.name] = nil
        end
        effects = compiled
        dur, t0 = 0, time()
        acting = player
        state = "exec"
      elseif result.type == "spell" then
        local spell = result.spell
        local compiled = compile_effects(spell.effects, spell.range)
        player.mp -= 1
        effects = compiled
        dur, t0 = 0, time()
        acting = player
        state = "exec"
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
      if player.state ~= "dead" then
        player.state = "idle"
      end
      dec_status(acting)

      if player.hp <= 0 then
        state = "lose"
      elseif enemy.hp <= 0 then
        state = "win"
      elseif acting == player then
        if enemy.sleep then
          effects = { { t = "message", target = enemy, text = "sleep" } }
          acting = enemy
          t0, dur = time(), 0

          state = "exec"
        else
          state = "enemy_turn"
        end
      elseif acting == enemy then
        state = "player_turn"
        action_menu = action_menu_new(enemy.sleep)
      end
    elseif state == "win" and btnp(4) then
      return "win", enemy.coins
    elseif state == "lose" and btnp(4) then
      return "lose"
    elseif state == "escape" and btnp(4) then
      return "escape"
    end
  end

  function me:draw()
    cls()
    draw_background()
    draw_unit(enemy, camera_x + 32, camera_y + 32)
    draw_unit(player, camera_x + 72, camera_y + 32)

    if state == "player_turn" then
      action_menu:draw()
    elseif state == "win" then
      draw_message("v i c t o r y", 7)
    elseif state == "lose" then
      draw_message("d e f e a t", 8)
    elseif state == "escape" then
      draw_message("e s c a p e d", 6)
    end
  end

  return me
end