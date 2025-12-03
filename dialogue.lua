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

-- segment = { text = string, action = () => () }
function dialogue_linear_new(npc_sprite_id, title, segments)
  local menu_map = {}

  for i, segment in ipairs(segments) do
    local state_key = tostring(i)
    local next_state_key = i < #segments and tostring(i + 1) or "leave"

    menu_map[state_key] = menu_new(
      title,
      segment.text,
      { next_state_key },
      nil,
      segment.action,
      function(key) return key == "leave" and key or "continue" end,
      100, 80
    )
  end

  local menu_tree = menu_tree_new("1", menu_map, { "leave" })

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
        global.items[item.name] = { item = item, quantity = 0 }
      end
      global.items[item.name].quantity += 1
    end,
    function(item)
      local name = pad_str(item.name, 8)
      local price = pad_str("$" .. item.price, 5)
      local num_owned = global.items[item.name] and global.items[item.name].quantity or 0
      local owned = "owned: " .. num_owned
      return name .. price .. owned
    end,
    100, 80
  )

  return dialogue_simple_new(npc_sprite_id, menu)
end

function inn_dialogue_new(npc_sprite_id, cost)
  local menu = menu_new(
    "inn",
    nil,
    { "rest $" .. cost },
    function(item) return global.coins >= cost end,
    function(item)
      global.coins -= cost
      global.player.hp = global.player.max_hp
      global.player.mp = global.player.max_mp
    end,
    nil,
    100, 80
  )

  return dialogue_simple_new(npc_sprite_id, menu)
end

function wizard_dialogue_new()
  local text1 = [[
i will teach you a
spell to lull your
foes to slumber.

then you can escape
if you do not wish
to fight!
]]

  local text2 = [[
these wood are haunted
by the dark elf's
creatures.

beware the dragon!
  ]]

  local function action1()
    global.player.max_mp += 1
    global.player.mp = global.player.max_mp
    add(global.spells, sleep_spell)
  end

  local segments = {
    { text = text1, action = action1 },
    { text = text2, action = function() end }
  }

  return dialogue_linear_new(43, "wizard", segments)
end

function fairy_cave_1_new()
  local text1 = [[
the dark elf cap-
tured us and set
the dragon to guard
this cave!

we will show you a
path through the
forest.
]]

  local text2 = [[
there are more of us
further in. we will
help you if we can.
]]

  local function action2()
    global.player.max_mp += 1
    global.player.mp = global.player.max_mp
    add(global.spells, sleep_spell)
  end

  local segments = {
    {
      text = text1, action = function()
        mset(3, 14, 11)
        mset(3, 15, 11)
        mset(4, 15, 11)
        mset(5, 15, 11)
      end
    },
    {
      text = text2, action = function() end
    }
  }

  return dialogue_linear_new(41, "fairies", segments)
end

dialogue_town_shop = shop_dialogue_new(4, global.shop_items)
dialogue_town_inn = inn_dialogue_new(4, 3)
dialogue_wizard_tower = wizard_dialogue_new()
dialogue_fairy_cave_1 = fairy_cave_1_new()