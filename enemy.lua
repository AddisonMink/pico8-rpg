function attack_behavior(enemy, player)
  return {
    name = "attack",
    effects = { { t = "attack", target = player } }
  }
end

function goblin_new()
  return {
    sprite_id = 236,
    coins = 1,
    hp = 20,
    behavior = attack_behavior
  }
end

function hobgoblin_new()
  return {
    sprite_id = 234,
    coins = 3,
    hp = 20,
    armor = true,
    behavior = attack_behavior
  }
end