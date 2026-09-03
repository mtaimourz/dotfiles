-- Rectangle-style window snapping.
--
-- Rectangle snaps a window to a region of the screen; Hyprland tiles it into
-- whatever the layout decides. The two only meet if the window floats, so
-- every snap here floats the window first and CTRL+ALT+BACKSPACE ("restore",
-- as in Rectangle) hands it back to the tiling layout.
--
-- Geometry is in Hyprland's logical coordinates: monitor.x/y are already
-- logical, monitor.width/height are the mode in physical pixels, so those two
-- are divided by the scale. The bar's reserved strip is subtracted, gaps_out
-- becomes the margin against the screen edges and gaps_in the seam between
-- snapped windows, so a snapped pair lines up with what the tiling layout
-- would have drawn.

local M = {}

-- { column, row, columns spanned, rows spanned } in a 2x2 grid.
local CELLS = {
  left = { 0, 0, 1, 2 },
  right = { 1, 0, 1, 2 },
  top = { 0, 0, 2, 1 },
  bottom = { 0, 1, 2, 1 },
  ["top-left"] = { 0, 0, 1, 1 },
  ["top-right"] = { 1, 0, 1, 1 },
  ["bottom-left"] = { 0, 1, 1, 1 },
  ["bottom-right"] = { 1, 1, 1, 1 },
  full = { 0, 0, 2, 2 },
}

-- gaps_in/gaps_out and reserved all come back as {left,right,top,bottom}, but
-- a bare number is a legal config value, so accept either.
local function edges(value, fallback)
  if type(value) == "number" then
    return { left = value, right = value, top = value, bottom = value }
  end
  if type(value) == "table" then
    return {
      left = value.left or fallback,
      right = value.right or fallback,
      top = value.top or fallback,
      bottom = value.bottom or fallback,
    }
  end
  return { left = fallback, right = fallback, top = fallback, bottom = fallback }
end

local function config_edges(key, fallback)
  local ok, value = pcall(hl.get_config, key)
  return edges(ok and value or nil, fallback)
end

-- The rectangle a snapped window may occupy, plus the seam between neighbours.
local function usable(monitor)
  local scale = monitor.scale
  if not scale or scale == 0 then
    scale = 1
  end

  local reserved = edges(monitor.reserved, 0)
  local out = config_edges("general.gaps_out", 10)
  local inner = config_edges("general.gaps_in", 5)

  local x = monitor.x + reserved.left + out.left
  local y = monitor.y + reserved.top + out.top
  local width = (monitor.width / scale) - reserved.left - reserved.right - out.left - out.right
  local height = (monitor.height / scale) - reserved.top - reserved.bottom - out.top - out.bottom

  return {
    x = x,
    y = y,
    w = width,
    h = height,
    seam_x = inner.left + inner.right,
    seam_y = inner.top + inner.bottom,
  }
end

local function box_for(monitor, where)
  local cell = CELLS[where]
  if not cell then
    return nil
  end

  local area = usable(monitor)
  local column, row, columns, rows = cell[1], cell[2], cell[3], cell[4]

  local unit_w = (area.w - area.seam_x) / 2
  local unit_h = (area.h - area.seam_y) / 2

  return {
    x = area.x + column * (unit_w + area.seam_x),
    y = area.y + row * (unit_h + area.seam_y),
    w = columns * unit_w + (columns - 1) * area.seam_x,
    h = rows * unit_h + (rows - 1) * area.seam_y,
  }
end

local function place(win, box)
  local target = "address:" .. win.address

  if (win.fullscreen or 0) ~= 0 then
    hl.dispatch(hl.dsp.window.fullscreen_state({ internal = 0, client = 0, window = target }))
  end

  if not win.floating then
    hl.dispatch(hl.dsp.window.float({ action = "on", window = target }))
  end

  hl.dispatch(hl.dsp.window.resize({ x = math.floor(box.w), y = math.floor(box.h), window = target }))
  hl.dispatch(hl.dsp.window.move({ x = math.floor(box.x), y = math.floor(box.y), window = target }))
end

-- Snap the focused window to one of the CELLS regions.
function M.snap(where)
  local win = hl.get_active_window()
  if not win then
    return
  end

  local monitor = win.monitor or hl.get_active_monitor()
  if not monitor then
    return
  end

  local box = box_for(monitor, where)
  if box then
    place(win, box)
  end
end

-- Rectangle's Center: keep the window's size, move it to the middle.
function M.center()
  local win = hl.get_active_window()
  if not win then
    return
  end

  local monitor = win.monitor or hl.get_active_monitor()
  if not monitor then
    return
  end

  local area = usable(monitor)
  local size = win.size
  local width = math.min(size[1] or area.w, area.w)
  local height = math.min(size[2] or area.h, area.h)

  place(win, {
    x = area.x + (area.w - width) / 2,
    y = area.y + (area.h - height) / 2,
    w = width,
    h = height,
  })
end

-- Rectangle's Restore: give the window back to the tiling layout.
function M.untile()
  local win = hl.get_active_window()
  if not win or not win.floating then
    return
  end

  hl.dispatch(hl.dsp.window.float({ action = "off", window = "address:" .. win.address }))
end

return M
