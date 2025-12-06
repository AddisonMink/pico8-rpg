function status_menu_new()
  local status_menu, item_menu, spell_menu
  local state = "status"
  local item_list = table_values(global.items)
  local me = {}

  -- #region initialization
  status_menu = menu_new(
    "status",
    nil,
    { "item", "spell" },
    function(action)
      return action == "spell" and #global.spells > 0
          or action == "item" and #table_values(global.items) > 0
    end,
    nil,
    nil,
    120,
    80
  )

  item_menu = menu_new(
    "item",
    nil,
    item_list,
    function(item) return item.item.name == "potion" end,
    function(item)
      item.quantity -= 1
      global.player.hp = min(global.player.hp + 30, global.player.max_hp)
      if item.quantity <= 0 then
        global.items[item.item.name] = nil
        del(item_list, item)
      end
    end,
    function(item)
      return pad_str(item.item.name .. " x" .. item.quantity, 12) .. item.item.desc
    end,
    120,
    80
  )

  spell_menu = menu_new(
    "spell",
    nil,
    global.spells,
    function() return false end,
    nil,
    nil,
    function(spell)
      return pad_str(spell.name, 10) .. spell.desc
    end,
    120,
    80
  )
  -- #endregion

  function me:update()
    if state == "status" then
      local result = status_menu:update()
      if result == "spell" then
        state = "spell"
      elseif result == "item" then
        state = "item"
      elseif result == "cancel" then
        return "cancel"
      end
    elseif state == "item" then
      local result = item_menu:update()
      if result == "cancel" or #item_list == 0 then
        state = "status"
      end
    elseif state == "spell" then
      local result = spell_menu:update()
      if result == "cancel" then
        state = "status"
      end
    end
  end

  function me:draw()
    local camera_x, camera_y = peek2(0x5f28), peek2(0x5f2a)
    local x, y = camera_x + 4, camera_y + 16
    if state == "status" then
      status_menu:draw(x, y)
    elseif state == "item" then
      item_menu:draw(x, y)
    elseif state == "spell" then
      spell_menu:draw(x, y)
    end
  end

  return me
end