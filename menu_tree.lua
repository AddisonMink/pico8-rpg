--[[
  arguments:
    state (string) - initial state key
    menu_map (table) - map of state keys to menu objects
    terminals (table) - array of terminal state keys
    allow_cancel (boolean, optional) - enable cancel navigation

  methods:
    update() -> string or nil
      returns:
        terminal (string) - if terminal state reached
        nil - if still navigating

    draw(x, y)
]]

function menu_tree_new(state, menu_map, terminals, allow_cancel)
  local prev_state = nil
  local terminals_set = {}
  local me = {}

  -- #regtion initialization
  for t in all(terminals) do
    terminals_set[t] = true
  end
  -- #endregion

  function me:update()
    local menu = menu_map[state]
    local result = menu:update()
    if not result then return end

    if allow_cancel and result == "cancel" then
      state = prev_state or state
    elseif result and menu_map[result] then
      prev_state = state
      state = result
    elseif terminals_set[result] then
      return result
    end
  end

  function me:draw(x, y)
    menu_map[state]:draw(x, y)
  end

  return me
end