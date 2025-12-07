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

-- segment = { text = string, action = function() => () }
function menu_list_new(title, segments)
  local state = 1
  local menus = {}

  for segment in all(segments) do
    local last = state == #segments
    local next_state = last and nil or state + 1
    local elem = last and "leave" or "continue"
    local on_select = segment.action or function() end
    local menu = menu2_new({
      title = title,
      text = segment.text,
      elems = { elem },
      on_select = on_select,
      next_state = function()
        return not last and next_state
      end
    })
    add(menus, menu)
    state = next_state
  end

  return menu_graph_new(1, menus)
end