function dialogue_new(npc_sprite_id, menu_tree)
  local me = {}

  function me:update()
    menu_tree:update()
  end

  function me:draw()
    spr(npc_sprite_id, 0, 0, 2, 2)
    menu_tree:draw(16, 32)
  end

  return me
end