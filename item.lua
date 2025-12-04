potion_item = {
  name = "potion",
  price = 1,
  range = "self",
  desc = "restore 30 hp",
  effects = { { t = "heal", amount = 30 } }
}

bomb_item = {
  name = "bomb",
  price = 2,
  range = "enemy",
  desc = "20 fire damage",
  effects = { 
    { t = "animation", id = 160 },
    { t = "damage", power = 20, magic = true } 
  }
}