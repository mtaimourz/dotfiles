local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- Work around the current NVIDIA/Plasma Wayland explicit-sync crash in the
-- Flatpak build by running WezTerm through XWayland.
config.enable_wayland = false

-- Plasma is scaled to 195%, but this XWayland window otherwise renders at
-- 100%.  Match the desktop's effective DPI (96 * 1.95).
config.dpi = 187.2

config.font = wezterm.font("MesloLGS NF")
config.font_size = 10.0
config.line_height = 1.0

config.color_scheme = "Ptyxis Match"
config.color_schemes = {
  ["Ptyxis Match"] = {
    foreground = "#f6f5f4",
    background = "#191d28",
    cursor_bg = "#f6f5f4",
    cursor_fg = "#191d28",
    cursor_border = "#f6f5f4",
    selection_fg = "#f6f5f4",
    selection_bg = "#353b4a",
    ansi = {
      "#171717",
      "#ed333b",
      "#33d17a",
      "#f6d32d",
      "#3584e4",
      "#c061cb",
      "#33c7de",
      "#deddda",
    },
    brights = {
      "#5e5e5e",
      "#f66151",
      "#57e389",
      "#f8e45c",
      "#62a0ea",
      "#dc8add",
      "#56e3ef",
      "#ffffff",
    },
  },
}

config.window_background_opacity = 0.94
config.text_background_opacity = 1.0
config.window_padding = {
  left = 6,
  right = 6,
  top = 4,
  bottom = 4,
}

config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = false
-- Let the formatter below expand tabs to share the whole window width.
config.tab_max_width = 999
-- Keep a distinct window title row above the tabs, like Ptyxis.
config.window_decorations = "TITLE|RESIZE"
config.window_frame = {
  font = wezterm.font("Noto Sans", { weight = "Bold" }),
  -- Match the comfortably-sized header used by the desktop terminal.
  font_size = 14.0,
  active_titlebar_bg = "#1e2433",
  inactive_titlebar_bg = "#1e2433",
  active_titlebar_fg = "#f6f5f4",
  inactive_titlebar_fg = "#c0bfbc",
  button_fg = "#f6f5f4",
  button_bg = "#1e2433",
  button_hover_fg = "#ffffff",
  button_hover_bg = "#343b4d",
}

-- Fancy tabs normally hug their labels.  Center each label inside an equal
-- share of the available terminal width, leaving room for the new-tab and
-- integrated window buttons on the right.
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  -- This WezTerm release does not expose pane dimensions to this callback.
  -- At the corrected DPI, about 220 Noto Sans characters span the usable
  -- width of this display.
  local available_columns = 220
  local tab_width = math.max(12, math.floor(available_columns / #tabs))
  local title = tab.active_pane.title

  if #title > tab_width - 2 then
    title = title:sub(1, tab_width - 3) .. "…"
  end

  local padding = tab_width - #title
  local left = math.floor(padding / 2)
  local right = padding - left

  return string.rep(" ", left) .. title .. string.rep(" ", right)
end)
config.colors = {
  tab_bar = {
    background = "#1e2433",
    active_tab = {
      bg_color = "#343b4d",
      fg_color = "#f6f5f4",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#1e2433",
      fg_color = "#c0bfbc",
    },
    inactive_tab_hover = {
      bg_color = "#2a3142",
      fg_color = "#ffffff",
    },
    new_tab = {
      bg_color = "#1e2433",
      fg_color = "#f6f5f4",
    },
    new_tab_hover = {
      bg_color = "#343b4d",
      fg_color = "#ffffff",
    },
  },
}

config.default_cursor_style = "SteadyBlock"
config.audible_bell = "Disabled"
config.window_close_confirmation = "NeverPrompt"

config.keys = {
  { key = "1", mods = "CTRL", action = act.ActivateTab(0) },
  { key = "2", mods = "CTRL", action = act.ActivateTab(1) },
  { key = "3", mods = "CTRL", action = act.ActivateTab(2) },
  { key = "4", mods = "CTRL", action = act.ActivateTab(3) },
  { key = "5", mods = "CTRL", action = act.ActivateTab(4) },
  { key = "6", mods = "CTRL", action = act.ActivateTab(5) },
  { key = "7", mods = "CTRL", action = act.ActivateTab(6) },
  { key = "8", mods = "CTRL", action = act.ActivateTab(7) },
  { key = "9", mods = "CTRL", action = act.ActivateTab(8) },
  { key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
  { key = "`", mods = "CTRL", action = act.ActivateLastTab },
  { key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
}

return config
