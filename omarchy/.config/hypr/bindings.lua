-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Override browser binding to use Google Chrome instead of Chromium
hl.unbind("SUPER + SHIFT + RETURN")
o.bind("SUPER + SHIFT + RETURN", "Browser", "google-chrome-stable --new-window")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Open another window of whatever app is focused. With the focused window
-- grouped (SUPER+G), Hyprland's auto_group makes it a new tab in that group --
-- the way SUPER+RETURN does for the terminal, but for Chrome and everything else.
o.bind("SUPER + CTRL + G", "New window of focused app", "hypr-new-window-of-focused")

-- Voxtype dictation with input capture so it works even when an input is focused
hl.unbind("SUPER + CTRL + X")
o.bind("SUPER + CTRL + X", "Toggle dictation", "voxtype record toggle", { allow_input_capture = true })

hl.unbind("F9")
o.bind("F9", "Start dictation (push-to-talk)", "voxtype record start", { allow_input_capture = true })
o.bind("F9", "Stop dictation (push-to-talk)", "voxtype record stop", { release = true, allow_input_capture = true })

-- Chromium (Chrome, Brave) drops its tab strip the moment the compositor tells
-- it that it is fullscreen, so SUPER+F used to cost the tabs. Fill the monitor
-- without telling the app and the tabs stay put. A page's own fullscreen (F11,
-- a video's fullscreen button) is unaffected.
hl.unbind("SUPER + F")
o.bind("SUPER + F", "Full screen", "hypr-fullscreen-keep-ui")

-- macOS habits: CMD+M minimizes to the dock, CMD+` walks the windows of the
-- app you are in. See hypr/mac.lua for how "minimize" is faked on a compositor
-- that has no such concept.
local mac = require("hypr.mac")

o.bind("SUPER + M", "Minimize window", mac.minimize)
o.bind("SUPER + SHIFT + M", "Unminimize last window", mac.unminimize_last)
o.bind("SUPER + GRAVE", "Next window of this app", function() mac.cycle_app_windows(true) end)
o.bind("SUPER + SHIFT + GRAVE", "Previous window of this app", function() mac.cycle_app_windows(false) end)

-- Rectangle's keymap, unchanged, on top of the tiling layout: a snap floats the
-- window into the region, CTRL+ALT+BACKSPACE gives it back to the tiler.
local rect = require("hypr.rectangle")

o.bind("CTRL + ALT + LEFT", "Snap window left half", function() rect.snap("left") end)
o.bind("CTRL + ALT + RIGHT", "Snap window right half", function() rect.snap("right") end)
o.bind("CTRL + ALT + UP", "Snap window top half", function() rect.snap("top") end)
o.bind("CTRL + ALT + DOWN", "Snap window bottom half", function() rect.snap("bottom") end)

o.bind("CTRL + ALT + U", "Snap window top left", function() rect.snap("top-left") end)
o.bind("CTRL + ALT + I", "Snap window top right", function() rect.snap("top-right") end)
o.bind("CTRL + ALT + J", "Snap window bottom left", function() rect.snap("bottom-left") end)
o.bind("CTRL + ALT + K", "Snap window bottom right", function() rect.snap("bottom-right") end)

o.bind("CTRL + ALT + RETURN", "Maximize window", function() rect.snap("full") end)
o.bind("CTRL + ALT + C", "Center window", rect.center)
o.bind("CTRL + ALT + BACKSPACE", "Return window to tiling", rect.untile)
