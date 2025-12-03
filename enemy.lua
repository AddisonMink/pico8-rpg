function attack_behavior(enemy, player, power)
  return {
    name = "attack",
    effects = { { t = "attack", target = player, power = power } }
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

function dragon_new()
  return {
    sprite_id = 230,
    coins = 10,
    hp = 50,
    behavior = function(enemy, player)
      local choice = flr(rnd(3))
      if choice == 0 then
        return {
          name = "breath",
          effects = {
            { t = "animation", id = 160, target = player },
            { t = "damage", power = 50, magic = true, target = player}
          }
        }
      else
        return attack_behavior(enemy, player, 20)
      end
    end
  }
end