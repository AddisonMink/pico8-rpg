function status_menu_new()
  local item_list = table_values(global.items)

  local status_menu = menu2_new({
    title = "status",
    elems = { "item", "spell" },
    validate_elem = function(action)
      return action == "spell" and #global.spells > 0
          or action == "item" and #table_values(global.items) > 0
    end,
    next_state = function(e) return e end,
    min_width = 120,
    min_height = 80
  })

  local item_menu = menu2_new({
    title = "item",
    elems = item_list,
    validate_elem = function(item) return item.item.name == "potion" end,
    on_select = function(item)
      item.quantity -= 1
      global.player.hp = min(global.player.hp + 30, global.player.max_hp)
      if item.quantity <= 0 then
        global.items[item.item.name] = nil
        del(item_list, item)
      else
        return "repeat"
      end
    end,
    stringify_elem = function(item)
      return pad_str(item.item.name .. " x" .. item.quantity, 12) .. item.item.desc
    end,
    min_width = 120,
    min_height = 80
  })

  local spell_menu = menu2_new({
    title = "spell",
    elems = global.spells,
    validate_elem = function() return false end,
    stringify_elem = function(spell)
      return pad_str(spell.name, 10) .. spell.desc
    end,
    min_width = 120,
    min_height = 80
  })

  local menu_graph = menu_graph_new(
    "status",
    {
      status = status_menu,
      item = item_menu,
      spell = spell_menu
    },
    true
  )

  local me = {}

  function me:update()
    return menu_graph:update()
  end

  function me:draw()
    local camera_x, camera_y = peek2(0x5f28), peek2(0x5f2a)
    menu_graph:draw(camera_x, camera_y + 16)
  end

  return me
end