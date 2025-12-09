function town_new()
  local credits = 5
  local me = {}

  local function save()
    saved.player.max_hp = global.player.max_hp
    saved.player.max_mp = global.player.max_mp
    saved.spells = global.spells
    saved.coins = global.coins
    global.player.hp = global.player.max_hp
    global.player.mp = global.player.max_mp
    global.items = {}

    for tile_change in all(global.tile_changes) do
      add(saved.tile_changes, tile_change)
    end

    for data_id, state in pairs(global.dialogue_states) do
      saved.dialogue_states[data_id] = state
    end
  end

  local start_menu = menu2_new({
    title = "town",
    text = { "welcome back!" },
    elems = { "rest and save" },
    next_state = function() return "rest" end,
    npc_sprite_id = 4
  })

  local rest_menu = menu2_new({
    title = "rest",
    text = { "hp and mp restored!" },
    elems = { "buy items" },
    on_select = save,
    next_state = function() return "item" end,
    npc_sprite_id = 4
  })

  local item_text = { "credits: " .. credits }

  local item_menu = menu2_new({
    title = "items",
    text = item_text,
    elems = { potion_item, bomb_item, "continue" },
    validate_elem = function(e)
      return type(e) == "string" or credits >= e.price
    end,
    stringify_elem = function(e)
      if type(e) == "string" then return e end
      local name = pad_str(e.name, 8)
      local price = pad_str("$" .. e.price, 5)
      local num_owned = global.items[e.name] and global.items[e.name].quantity or 0
      local owned = "owned: " .. num_owned
      return name .. price .. owned
    end,
    on_select = function(e)
      if type(e) == "string" then return end
      credits -= e.price
      item_text[1] = "credits: " .. credits
      if global.items[e.name] == nil then
        global.items[e.name] = { type = "item", item = e, quantity = 0 }
      end
      global.items[e.name].quantity += 1
      return "repeat"
    end,
    npc_sprite_id = 4
  })

  local menu_graph = menu_graph_new(
    "start",
    {
      start = start_menu,
      rest = rest_menu,
      item = item_menu
    }
  )

  function me:update()
    return menu_graph:update()
  end

  function me:draw()
    menu_graph:draw()
  end

  return me
end