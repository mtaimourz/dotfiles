-- macOS-style minimize, and cycling the windows of one app.
--
-- Hyprland has no minimize. The nearest equivalent is a special workspace: it
-- hides a window without unmapping it, so the window keeps its foreign-toplevel
-- handle and the dock goes on listing it -- running dot, hover preview, window
-- stack and all -- exactly the way a minimized app stays in the macOS dock.
--
-- Each minimized window gets a special workspace of its own, keyed on its
-- stable id, rather than all of them sharing one. Sharing looks tidier and is
-- wrong: showing a special workspace focuses whatever was last focused on it,
-- so asking for one minimized window surfaces another on the way, and the hook
-- below would restore that one too. Alone on its own workspace, a window can
-- only ever surface itself. The workspaces are reaped as they empty.
--
-- Restoring is the part that needs the hook. Focusing a window that lives on a
-- special workspace only pops that workspace up as an overlay, so clicking the
-- dock icon would leave the window floating over whatever workspace you are on
-- rather than putting it back where it came from. window.active closes that
-- gap: whenever a minimized window becomes active -- from the dock, from
-- SUPER+grave, from anywhere at all -- it is moved back to the workspace it was
-- minimized from first.

local M = {}

local PREFIX = "special:minimized-"

-- address -> name of the workspace the window was minimized from
local origin = {}
-- addresses, most recently minimized first
local stack = {}
-- restoring moves a window, which re-enters window.active; guard against that
local restoring = false

local function sel(win)
  return "address:" .. win.address
end

local function unstack(address)
  for i = #stack, 1, -1 do
    if stack[i] == address then
      table.remove(stack, i)
    end
  end
end

local function forget(address)
  origin[address] = nil
  unstack(address)
end

local function is_minimized(win)
  local workspace = win and win.workspace
  return workspace ~= nil and workspace.name:sub(1, #PREFIX) == PREFIX
end

-- Dismiss the overlay if it is still up. Hyprland reaps a special workspace as
-- its last window leaves, so this is belt and braces.
local function hide_overlay(monitor)
  monitor = monitor or hl.get_active_monitor()
  if not monitor then
    return
  end

  local showing = monitor.active_special_workspace
  if not showing or showing.name:sub(1, #PREFIX) ~= PREFIX then
    return
  end

  pcall(function()
    monitor:set_special_workspace(nil)
  end)
end

local function restore(win)
  if not win or restoring then
    return
  end

  restoring = true

  local address = win.address
  local monitor = win.monitor
  local target = origin[address]

  -- The workspace it came from may have been emptied and reaped since. Moving
  -- to a name Hyprland no longer knows recreates it, which is what we want.
  if not target then
    local current = hl.get_active_workspace()
    target = current and current.name or "1"
  end

  hide_overlay(monitor)
  hl.dispatch(hl.dsp.window.move({ workspace = target, window = "address:" .. address, follow = true }))
  hl.dispatch(hl.dsp.focus({ window = "address:" .. address }))
  forget(address)

  restoring = false
end

-- Minimize the focused window (macOS CMD+M).
function M.minimize()
  local win = hl.get_active_window()
  if not win or is_minimized(win) then
    return
  end

  -- A fullscreen window that comes back from a special workspace still
  -- believes it owns the monitor, so drop the state on the way down.
  if (win.fullscreen or 0) ~= 0 then
    hl.dispatch(hl.dsp.window.fullscreen_state({ internal = 0, client = 0, window = sel(win) }))
  end

  local workspace = win.workspace
  unstack(win.address)
  origin[win.address] = workspace and not workspace.special and workspace.name or nil
  table.insert(stack, 1, win.address)

  hl.dispatch(hl.dsp.window.move({
    workspace = PREFIX .. tostring(win.stable_id),
    window = sel(win),
    follow = false,
  }))
end

-- Bring back the most recently minimized window that is still around.
function M.unminimize_last()
  while #stack > 0 do
    local address = stack[1]
    local win = hl.get_window("address:" .. address)
    if win and is_minimized(win) then
      restore(win)
      return
    end
    forget(address)
  end
end

-- Cycle the windows of the focused window's app (macOS CMD+grave). Windows on
-- other workspaces are included -- focusing one follows it there, the way
-- switching windows on macOS follows the app to its space -- and so are
-- minimized ones, which the restore hook puts back as they take focus.
function M.cycle_app_windows(forward)
  local active = hl.get_active_window()
  if not active then
    return
  end

  local class = active.class
  local siblings = {}
  for _, win in ipairs(hl.get_windows() or {}) do
    if win.class == class and win.mapped then
      siblings[#siblings + 1] = win
    end
  end

  if #siblings < 2 then
    return
  end

  -- stable_id is assigned at map time, so this is creation order: steady while
  -- you cycle, unlike focus order, which the cycling itself keeps rewriting.
  table.sort(siblings, function(a, b)
    return a.stable_id < b.stable_id
  end)

  local index = 1
  for i, win in ipairs(siblings) do
    if win.address == active.address then
      index = i
      break
    end
  end

  local step = forward == false and -1 or 1
  local next_index = ((index - 1 + step) % #siblings) + 1

  hl.dispatch(hl.dsp.focus({ window = "address:" .. siblings[next_index].address }))
end

-- Every route into a minimized window lands here, so the dock, the window stack
-- and the keyboard all restore identically.
hl.on("window.active", function(win)
  if is_minimized(win) then
    restore(win)
  end
end)

hl.on("window.close", function(win)
  if win and win.address then
    forget(win.address)
  end
end)

return M
