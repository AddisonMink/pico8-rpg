function dialogue_new(npc_sprite_id, menu_tree)
  local me = {}

  function me:update()
    return menu_tree:update()
  end

  function me:draw()
    spr(npc_sprite_id, 32, 16, 2, 2)
    spr(global.player.sprite_id, 82, 16, 2, 2)
    menu_tree:draw(16, 40)
  end

  return me
end