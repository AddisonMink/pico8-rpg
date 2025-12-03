function action_menu_new(can_escape)
  local action_menu, item_menu, spell_menu
  local state = "action"
  local me = {}

  -- #region initialization
  action_menu = menu_new(
    "action",
    nil,
    { "attack", "spell", "item", "escape" },
    function(action)
      return action == "attack"
          or action == "spell" and global.player.mp > 0
          or action == "item" and #global.items > 0
          or action == "escape" and can_escape
    end
  )

  item_menu = menu_new(
    "item",
    nil,
    global.items,
    nil,
    nil,
    function(item)
      return item.name .. " x" .. item.quantity
    end
  )

  spell_menu = menu_new(
    "spell",
    nil,
    global.spells,
    nil,
    nil,
    function(spell)
      return pad_str(spell.name, 10) .. spell.desc
    end
  )
  -- #endregion

  function me:update()
    if state == "action" then
      local result = action_menu:update()
      if result == "attack" then
        return "attack"
      elseif result == "spell" then
        state = "spell"
      elseif result == "item" then
        state = "item"
      elseif result == "escape" then
        return "escape"
      end
    elseif state == "item" then
      local result = item_menu:update()
      if result == "cancel" then
        state = "action"
      elseif result ~= nil then
        return { type = "item", item = result }
      end
    elseif state == "spell" then
      local result = spell_menu:update()
      if result == "cancel" then
        state = "action"
      elseif result ~= nil then
        return { type = "spell", spell = result }
      end
    end
  end

  function me:draw()
    local camera_x, camera_y = peek2(0x5f28), peek2(0x5f2a)
    local x, y = camera_x + 8, camera_y + 128 - 56
    if state == "action" then
      action_menu:draw(x, y)
    elseif state == "item" then
      item_menu:draw(x, y)
    elseif state == "spell" then
      spell_menu:draw(x, y)
    end
  end

  return me
end