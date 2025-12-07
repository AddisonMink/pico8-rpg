function action_menu_new(can_escape)
  local action_menu = menu2_new({
    title = "action",
    elems = { "attack", "spell", "item", "escape" },
    validate_elem = function(action)
      return action == "attack"
          or action == "spell" and #global.spells > 0 and global.player.mp > 0
          or action == "item" and #table_values(global.items) > 0
          or action == "escape" and can_escape
    end,
    next_state = function(action)
      return (action == "spell" or action == "item") and action
    end
  })

  local item_menu = menu2_new({
    title = "item",
    elems = table_values(global.items),
    stringify_elem = function(item)
      return pad_str(item.item.name .. " x" .. item.quantity, 12) .. item.item.desc
    end
  })

  local spell_menu = menu2_new({
    title = "spell",
    elems = global.spells,
    stringify_elem = function(spell)
      return pad_str(spell.name, 10) .. spell.desc
    end
  })

  local menu_graph = menu_graph_new(
    "action",
    {
      action = action_menu,
      item = item_menu,
      spell = spell_menu
    },
    true
  )

  local me = {}

  function me:update()
    local result = menu_graph:update()
    if not result then return end

    if result.type == "cancel" then
      result = { type = "result", result = "attack" }
    end

    return result.result
  end

  function me:draw()
    local camera_x, camera_y = peek2(0x5f28), peek2(0x5f2a)
    local x, y = camera_x + 8, camera_y + 128 - 56
    menu_graph:draw(x, y)
  end

  return me
end