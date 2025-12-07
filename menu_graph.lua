function menu_graph_new(state, menus, allow_cancel)
  local prev_states = {}
  local me = {}

  function me:update()
    local result = menus[state]:update()
    if not result then return end

    if result.type == "result" then
      return result
    elseif result.type == "state" then
      add(prev_states, state)
      state = result.state
    elseif result.type == "cancel" and allow_cancel then
      if #prev_states > 0 then
        state = prev_states[#prev_states]
        prev_states[#prev_states] = nil
      else
        return result
      end
    end
  end

  function me:draw(x, y)
    menus[state]:draw(x, y)
  end

  return me
end