-- theme.lua  (port of theme.conf)
-- Included from hyprland.lua via dofile.

-- cursor + icon theme
hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 20")
hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'")
hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 20")
hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme 'Tela-circle-dracula'")

hl.config({
  general = {
    gaps_in = 3,
    gaps_out = 8,
    border_size = 3,
    col = {
      active_border   = { colors = { "rgb(b4befe)", "rgb(f5c2e7)" }, angle = 45 },
      inactive_border = "rgba(00000000)",
    },
    layout = "dwindle",
    resize_on_border = true,
  },
  decoration = {
    dim_special = 0.3,
    rounding = 10,
    blur = {
      enabled = true,
      special = true,
      size = 6,
      passes = 3,
      new_optimizations = true,
      ignore_opacity = true,
      xray = false,
    },
    shadow = {
      enabled = true,
      offset = "0 0",
      range = 18,
      render_power = 3,
      color = 0xee0d0d0d,
    },
  },
})
