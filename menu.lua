-- menu.lua

--[[
  types:
    OPTION - type of menu option. defaults to string.

  arguments:
    title (string, optional) - menu title
    text (string, optional) - body text, supports "\n"
    options (table, optional) - array of OPTION
    is_valid (function, optional) - is_valid(OPTION) -> boolean
    on_select (function, optional) - on_select(OPTION)
    stringify (function, optional) - stringify(OPTION) -> string
    min_width (number, optional) - minimum width of menu
    min_height (number, optional) - minimum height of menu

  methods:
    update() -> string or nil
      returns:
        option (string) - selected option
        "ok" - if no options and confirmed
        "cancel" - if cancelled
        nil - if no action

    reset() - resets index to first option
    draw(x, y) - draws menu at (x, y)
]]

function menu_new(title, text, options, is_valid, on_select, stringify, min_width, min_height)
  local w, h = 8, 8
  local text_height = 0
  local text_lines = {}
  local index = 1
  local me = {}

  -- #region initialization
  stringify = stringify or function(o) return o end

  if title then
    h += 6
    w = #title * 4 + 8
  end

  if text then
    text_lines = split(text, "\n")
    text_height = #text_lines * 6 + 4
    h += text_height
    for line in all(text_lines) do
      w = max(w, #line * 4 + 16)
    end
  end

  if options then
    h += 4 + #options * 8
    for o in all(options) do
      local str = stringify(o)
      w = max(w, #str * 4 + 16)
    end
  end

  options = options or {}
  is_valid = is_valid or function() return true end
  on_select = on_select or function() end
  w = max(w, min_width or 0)
  h = max(h, min_height or 0)
  -- #endregion

  function me:reset()
    index = 1
  end

  function me:update()
    index = btnp(2) and (index - 2) % #options + 1
        or btnp(3) and index % #options + 1
        or index

    if btnp(4) and #options == 0 then
      on_select()
      return "ok"
    elseif btnp(4) then
      local option = options[index]
      if is_valid(option) then
        on_select(option)
        return option
      end
    elseif btnp(5) then
      return "cancel"
    end
  end

  function me:draw(x, y)
    rectfill(x, y, x + w - 1, y + h - 1, 1)
    rect(x, y, x + w - 1, y + h - 1, 7)

    x += 4
    y += 4

    if title then
      print(title, x, y, 7)
      y += 10
    end

    if text then
      print(text, x, y, 7)
      y += text_height
    end

    for i, option in ipairs(options) do
      local c = is_valid(option) and 7 or 5
      print(stringify(option), x + 8, y, c)
      if i == index then
        spr(1, x, y)
      end
      y += 8
    end
  end

  return me
end