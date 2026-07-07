local HOME = os.getenv("HOME")
local D = HOME .. "/.config/hypr/"
--=========================== ENVIRONMENT ===========================
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
--=========================== AUTOSTART (exec-once) ===========================
-- Portals for screencast (Discord screenshare / OBS): sync the Wayland env FIRST,
-- then (re)start the portals, only at boot. Wrong order left the hyprland portal
-- unstarted -> black/broken capture. See ~/bin/init-portals.sh.
hl.exec_cmd(HOME .. "/bin/init-portals.sh")
hl.exec_cmd(HOME .. "/bin/polkitkdeauth.sh")
hl.exec_cmd("sh -c 'source ~/.env'")
-- long-running daemons, guarded so a reload won't spawn duplicates
local function daemon(proc, cmd) hl.exec_cmd("sh -c 'pgrep -x " .. proc .. " >/dev/null || " .. (cmd or proc) .. "'") end
daemon("swaync")
daemon("hypridle")
daemon("udiskie", "udiskie --no-automount --smart-tray")
-- NOTE: swww-daemon is started by apply-theme-wallpaper.sh (below) on the REAL
-- WAYLAND_DISPLAY; starting it here (too early) bound it to wayland-0 → black bg.
hl.exec_cmd("sh -c 'pgrep -f \"wl-paste --type text\" >/dev/null || wl-paste --type text --watch cliphist store'")
hl.exec_cmd("sh -c 'pgrep -f \"wl-paste --type image\" >/dev/null || wl-paste --type image --watch cliphist store'")
hl.exec_cmd(HOME .. "/bin/start-waybar.sh")
hl.exec_cmd(HOME .. "/bin/apply-theme-wallpaper.sh")

--=========================== INPUT / DEVICES / GESTURES ===========================
hl.config({
  input = {
    kb_layout = "us,ara",
    kb_options = "grp:alt_shift_toggle",
    follow_mouse = 1,
    sensitivity = 0,
    force_no_accel = 1,
    touchpad = { natural_scroll = false },
  },
})


hl.device({ name = "wireless-controller-touchpad", enabled = false })
hl.device({ name = "epic mouse V1", sensitivity = 0 })
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

--=========================== LAYOUTS / MISC / XWAYLAND ===========================
hl.config({
  dwindle = { preserve_split = true },
  master  = { new_status = "master" },
  misc = {
    vrr = 0,
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    force_default_wallpaper = 0,
  },
  xwayland = { force_zero_scaling = true },
})

--=========================== INCLUDES (the other modules) ===========================
dofile(D .. "animations.lua")
dofile(D .. "keybindings.lua")
dofile(D .. "windowrules.lua")
dofile(D .. "theme.lua")
dofile(D .. "nvidia.lua")
dofile(D .. "monitors.lua")
dofile(D .. "custom-prefs.lua")

--=========================== FOCUSED WINDOW: no border, shadow instead ===========================
-- final override (was the tail of hyprland.conf; wins over theme/meowrch borders)
hl.config({
  general = { border_size = 0, col = { active_border = "rgba(00000000)", inactive_border = "rgba(00000000)" } },
  decoration = { shadow = { color = 0xee0d0d0d, color_inactive = 0x00000000 } },
})

--=========================== SCROLLOVERVIEW PLUGIN CONFIG + GESTURES ===========================
-- Load + configure the scrolloverview plugin on startup (async; hyprctl keyword
-- can't set plugin config in Lua mode, so the script uses hl.config via dispatch).
hl.exec_cmd(HOME .. "/bin/scrolloverview-setup.sh")
