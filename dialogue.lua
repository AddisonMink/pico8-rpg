function dialogue_new(data_id, npc_sprite_id, title, segments)
  local menu_list = menu_list_new(title, segments, npc_sprite_id)
  local me = {}

  function me:load()
    local loaded_state = global.dialogue_states[data_id]
    if loaded_state then
      menu_list:set_state(loaded_state)
    else
      menu_list:reset_state()
    end
  end

  function me:update()
    local result = menu_list:update()
    if result then
      local state = menu_list:get_state()
      global.dialogue_states[data_id] = state
      return result
    end
  end

  function me:draw()
    menu_list:draw()
  end

  return me
end

dialogue_wizard = dialogue_new(
  "wizard1",
  43,
  "wizard",
  {
    {
      "i will teach you a",
      "spell to lull your",
      "foes to slumber.",
      "",
      "then you can escape",
      "if you do not wish",
      "to fight!"
    },
    function()
      global.player.max_mp += 1
      global.player.mp = global.player.max_mp
      add(global.spells, sleep_spell)
    end,
    {
      "these woods are haunted",
      "by the dark elf's",
      "creatures.",
      "",
      "beware the dragon!"
    }
  }
)

dialogue_fairy_1 = dialogue_new(
  "fairy1",
  41,
  "fairies",
  {
    {
      "the dark elf cap-",
      "-tured us and set",
      "the dragon to guard",
      "this cave!",
      "",
      "we will show you a",
      "path through the",
      "forest."
    },
    function()
      set_tile(3, 14, 11)
      set_tile(3, 15, 11)
      set_tile(4, 15, 11)
      set_tile(5, 15, 11)
    end,
    {
      "there are more of",
      "us further in. we",
      "will help you if we",
      "can."
    }
  }
)

dialogue_fairy_2 = dialogue_new(
  "fairy2",
  41,
  "fairies",
  {
    {
      "we will show you the way",
      "out of the forest!"
    },
    function()
      set_tile(7, 20, 11)
      set_tile(8, 20, 11)
    end,
    {
      "good luck to you!"
    }
  }
)

dialogue_fairy_3 = dialogue_new(
  "fairy3",
  41,
  "fairies",
  {
    {
      "the dark elf is shrouded",
      "in illusion. there is a",
      "magic spell that can",
      "reveal him."
    },
    function() end
  }
)

dialogue_fairy_4 = dialogue_new(
  "fairy4",
  41,
  "fairies",
  {
    {
      "the dark elf's castle is",
      "just ahead. be careful!",
      "",
      "he is one of the red",
      "king's vassals. you will",
      "not be able to escape",
      "once you confront him."
    },
    {
      "let us heal your wounds",
      "before you go further."
    },
    function()
      global.player.hp = global.player.max_hp
      global.player.mp = global.player.max_mp
    end
  }
)

dialogue_fairy_5 = dialogue_new(
  "fairy5",
  41,
  "fairies",
  {
    {
      "we are the guardians",
      "of the sacred sping.",
      "",
      "drink from it to",
      "increase your power."
    },
    function()
      global.player.max_hp += 10
      global.strength += 10
      global.player.hp = global.player.max_hp
      global.player.mp = global.player.max_mp
    end,
    {
      "now that the dark",
      "elf is gone, we will",
      "show the townspeople",
      "how to make sacred",
      "water."
    }
  }
)

dialogue_priestess_1 = dialogue_new(
  "priestess1",
  66,
  "priestess",
  {
    {
      "i will teach you a",
      "spell to break evil",
      "enchantments.",
      "",
      "illusions and armor",
      "will shatter before",
      "it."
    },
    function()
      global.player.max_mp += 1
      global.player.mp = global.player.max_mp
      add(global.spells, dispel_spell)
    end,
    {
      "there will be more",
      "content here later."
    }
  }
)