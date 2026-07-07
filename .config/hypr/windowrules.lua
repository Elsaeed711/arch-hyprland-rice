-- windowrules.lua  (port of windowrules.conf)
-- Included from hyprland.lua via dofile.

local function op(class, o) hl.window_rule({ match = { class = class }, opacity = o }) end

-- opacity-only rules
op("^(firefox)$", "0.90 0.90")
op("^(org.telegram.desktop)$", "0.90 0.90")
op("^(nemo)$", "0.80 0.80")
op("^(Code)$", "0.80 0.80")
op("^(code-oss)$", "0.80 0.80")
op("^(code-url-handler)$", "0.80 0.80")
op("^(code-insiders-url-handler)$", "0.80 0.80")
op("^(com.obsproject.Studio)$", "0.80 0.80")
op("^(Alacritty)$", "0.40 0.40")
op("^(kitty)$", "0.70 0.30")
op("^([Ss]team)$", "0.80 0.80")
op("^(steamwebhelper)$", "0.80 0.80")
op("^(discord)$", "0.80 0.80")
op("^(WebCord)$", "0.80 0.80")
op("^(vesktop)$", "0.80 0.80")
op("^(polkit-gnome-authentication-agent-1)$", "0.80 0.80")
op("^(org.freedesktop.impl.portal.desktop.gtk)$", "0.80 0.80")
op("^(org.freedesktop.impl.portal.desktop.hyprland)$", "0.80 0.80")
op("^(evince)$", "0.80 0.80")

-- opacity + float (+ size/center)
hl.window_rule({ match = { class = "^(org.pulseaudio.pavucontrol)$" }, opacity = "0.80 0.80", float = true, size = "920 450" })
hl.window_rule({ match = { class = "^(qt5ct)$" }, opacity = "0.80 0.80", float = true })
hl.window_rule({ match = { class = "^(qt6ct)$" }, opacity = "0.80 0.80", float = true })
hl.window_rule({ match = { class = "^(org.kde.ark)$" }, opacity = "0.80 0.80", float = true })
hl.window_rule({ match = { class = "^(blueman-manager)$" }, opacity = "0.80 0.80", float = true })
hl.window_rule({ match = { class = "^(yad)$" }, opacity = "0.80 0.80", float = true })
hl.window_rule({ match = { class = "^(org.kde.polkit-kde-authentication-agent-1)$" }, opacity = "0.80 0.80", float = true })
hl.window_rule({ match = { class = "^(org.gnome.Loupe)$" }, opacity = "0.90 0.90", float = true, center = true, size = "1200 800" })
hl.window_rule({ match = { class = "^(gnome-calculator)$" }, opacity = "0.80 0.80", float = true, center = true, size = "360 500" })

-- float-only
hl.window_rule({ match = { class = "^(vlc)$" }, float = true })
hl.window_rule({ match = { class = "^(firefox)$", title = "^(Picture-in-Picture)$" }, float = true })
hl.window_rule({ match = { class = "^(firefox)$", title = "^(Library)$" }, float = true })

-- no blur for unnamed surfaces
hl.window_rule({ match = { class = "^()$", title = "^()$" }, no_blur = true })

-- ===== layer rules =====
for _, ns in ipairs({ "wofi", "notifications", "swaync-notification-window", "swaync-control-center", "waybar" }) do
  hl.layer_rule({ match = { namespace = ns }, blur = true, ignore_alpha = 0 })
end
hl.layer_rule({ match = { namespace = "logout_dialog" }, blur = true })
