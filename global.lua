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
  coins = 5,

  -- world data
  world_x = 13 * 8,
  world_y = 15 * 8,
  camera_x = (13 * 8) - 32,
  camera_y = (15 * 8) - 32,

  -- shop data
  shop_items = {
    potion_item,
    bomb_item
  }
}