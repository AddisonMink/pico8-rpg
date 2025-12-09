-- menu.lua

--[[
  types:
    ELEM - type of menu option. defaults to string.
    RESULT - return type of menu.
    STATE - string. next state identifier. for use in menu graph.

  arguments:
    title (string, optional) - menu title
    text (string, optional) - body text, supports "\n"
    elems (table, optional) - array of ELEM
    validate_elem (function, optional) - validate_elem(ELEM) -> boolean
    on_select (function, optional) - on_select(ELEM) -> RESULT
    next_state (function, optional) - next_state() -> STATE
    stringify_elem (function, optional) - stringify_elem(ELEM) -> string
    min_width (number, optional) - minimum width of menu
    min_height (number, optional) - minimum height of menu
    npc_sprite_id (number, optional) - sprite ID of the NPC

  methods:
    update() -> string or nil
      returns:
        { type = "result", result = RESULT } - selected option result
        { type = "state", state = STATE } - next state to transition to
        { type = "cancel" } - if cancelled
        nil - if no action

    draw(x, y) - draws menu at (x, y)
]]

function menu2_new(params)
  local title = params.title
  local text = params.text or {}
  local elems = params.elems or {}

  local validate_elem = params.validate_elem
      or function(e) return true end

  local stringify_elem = params.stringify_elem
      or function(e) return e end

  local on_select = params.on_select
      or function(e) return e end

  local next_state = params.next_state
      or function() return nil end

  local min_width = params.min_width or 100
  local min_height = params.min_height or 80
  local w, h = 0, 0
  local npc_sprite_id = params.npc_sprite_id
  local index = 1
  local me = {}

  local function initialize()
    if title then
      w = #title * 4
      h += 9
    end

    for line in all(text) do
      w = max(w, #line * 4)
      h += 6
    end

    if #text > 0 then
      h += 4
    end

    for _, e in ipairs(elems) do
      local str = stringify_elem(e)
      w = max(w, #str * 4 + 8)
      h += 8
    end

    w += 8
    h += 8
    w = max(w, min_width)
    h = max(h, min_height)
  end

  function me:update()
    index = btnp(2) and (index - 2) % #elems + 1
        or btnp(3) and index % #elems + 1
        or index

    if btnp(4) then
      local elem = elems[index]
      if not validate_elem(elem) then return end
      local result = on_select(elem)
      if result == "repeat" then
        return nil
      end
      local state = next_state(elem)
      if state then
        return { type = "state", state = state }
      else
        return { type = "result", result = result }
      end
    elseif btnp(5) then
      return { type = "cancel" }
    end
  end

  function me:draw(x, y)
    if not (x or y) then
      local camera_x = peek2(0x5f28)
      local camera_y = peek2(0x5f2a)
      x = camera_x + 64 - w / 2
      y = camera_y + 40
    end

    local cx, cy = x + 4, y + 4

    draw_panel(x, y, w, h)

    if title then
      print(title, cx, cy, 7)
      cy += 9
    end

    for line in all(text) do
      print(line, cx, cy, 7)
      cy += 6
    end

    if #text > 0 then cy += 4 end

    local pointer_y = cy + (index - 1) * 8

    for i, e in ipairs(elems) do
      local str = stringify_elem(e)
      local color = validate_elem(e) and 7 or 5
      print(str, cx + 8, cy, color)
      cy += 8
    end

    spr(1, cx, pointer_y)

    if npc_sprite_id then
      local x = peek2(0x5f28) + 32
      local y = y - 24
      spr(npc_sprite_id, x, y, 2, 2)
      spr(128, x + 50, y, 2, 2)
    end
  end

  initialize()
  return me
end