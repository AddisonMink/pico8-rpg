-- #region dialogue logic
function dialogue_new(npc_sprite_id, menu_tree)
  local me = {}

  function me:update()
    return menu_tree:update()
  end

  function me:draw()
    local camera_x = peek2(0x5f28)
    local camera_y = peek2(0x5f2a)
    spr(npc_sprite_id, camera_x + 32, camera_y + 16, 2, 2)
    spr(global.player.sprite_id, camera_x + 82, camera_y + 16, 2, 2)
    menu_tree:draw(camera_x + 16, camera_y + 40)
  end

  return me
end

function dialogue_simple_new(npc_sprite_id, menu)
  local menu_tree = menu_tree_new(
    "main",
    { main = menu },
    { "ok", "cancel" },
    true
  )
  return dialogue_new(npc_sprite_id, menu_tree)
end

function shop_dialogue_new(npc_sprite_id, items)
  local menu = menu_new(
    "shop",
    nil,
    items,
    function(item) return global.coins >= item.price end,
    function(item)
      global.coins -= item.price
      if global.items[item.name] == nil then
        global.items[item.name] = 0
      end
      global.items[item.name] += 1
    end,
    function(item)
      local name = pad_str(item.name, 8)
      local price = pad_str("$" .. item.price, 5)
      local owned = "owned: " .. (global.items[item.name] or 0)
      return name .. price .. owned
    end,
    100, 80
  )

  return dialogue_simple_new(npc_sprite_id, menu)
end
-- #endregion

dialogue_town_shop = shop_dialogue_new(4, global.shop_items)