local wezterm = require('wezterm')
local config = {
  --disable_default_key_bindings = true,
  font = wezterm.font_with_fallback({
    { family = 'JetBrains Mono NL' },
    { family = 'Noto Color Emoji' },
  }),
  color_scheme = "Breeze",
  --color_scheme = "Tokyo Night Storm",
  window_close_confirmation = "AlwaysPrompt",
  exit_behavior = "CloseOnCleanExit",
  hide_tab_bar_if_only_one_tab = true,
}
return config
