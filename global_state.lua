global = {
  -- player data
  player = {
    player = true,
    sprite_id = 128,
    hp = 50,
    max_hp = 50,
    mp = 0,
    max_mp = 0
  },
  strength = 10,
  spells = {},
  items = {},
  coins = 0,

  -- world data
  tile_changes = {},
  dialogue_states = {}
}

saved = {
  -- player data
  player = {
    max_hp = 50,
    max_mp = 0
  },
  spells = {},
  coins = 0,

  -- world data
  tile_changes = {},
  dialogue_states = {}
}

function set_tile(x, y, tile_id)
  mset(x, y, tile_id)
  add(global.tile_changes, { x = x, y = y, tile_id = tile_id })
end