--[[
  ~/.wezterm.lua にコピーまたはシンボリックリンクして使う。
  dotfiles の設定（.config/wezterm/wezterm.lua）を確実に読み込む。

  例: ln -sf "$HOME/.config/wezterm/wezterm-home.lua" "$HOME/.wezterm.lua"
]]
local home = os.getenv("HOME") or ""
local config_dir = home .. "/.config/wezterm"
package.path = package.path .. ";" .. config_dir .. "/?.lua"
return dofile(config_dir .. "/wezterm.lua")
