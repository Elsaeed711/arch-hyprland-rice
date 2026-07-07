-- keybindings.lua  (port of keybindings.conf)
-- Included from hyprland.lua via dofile.

local HOME = os.getenv("HOME")
local M   = "SUPER"          -- $mainMod
local SM  = "SUPER + SHIFT"  -- $subMod
local term = "kitty"

-- ===== system =====
hl.bind(M .. " + Return", hl.dsp.exec_cmd(term))
hl.bind(M .. " + E", hl.dsp.exec_cmd("nemo"))
hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd(term .. " -e btop"))
hl.bind(M .. " + W", hl.dsp.exec_cmd("python " .. HOME .. "/.config/meowrch/meowrch.py --action select-wallpaper"))
hl.bind(M .. " + T", hl.dsp.exec_cmd("python " .. HOME .. "/.config/meowrch/meowrch.py --action select-theme"))
hl.bind("Print", hl.dsp.exec_cmd("flameshot gui"))
hl.bind(M .. " + P", hl.dsp.exec_cmd("pavucontrol"))
hl.bind(M .. " + V", hl.dsp.exec_cmd("sh " .. HOME .. "/bin/rofi-menus/clipboard-manager.sh"))
hl.bind(M .. " + D", hl.dsp.exec_cmd("wofi --show drun"))
hl.bind(M .. " + Escape", hl.dsp.exec_cmd("wlogout -b 5 -c 0 -p layer-shell"))
hl.bind(M .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(M .. " + C", hl.dsp.exec_cmd("sh " .. HOME .. "/bin/color-picker.sh"))
hl.bind(M .. " + R", hl.dsp.exec_cmd("sh " .. HOME .. "/bin/toggle-bar.sh"))
hl.bind(M .. " + B", hl.dsp.exec_cmd("brave"))
hl.bind(SM .. " + D", hl.dsp.exec_cmd("python3 " .. HOME .. "/bin/dvd-bounce.py"))
hl.bind(SM .. " + R", hl.dsp.exec_cmd("sh " .. HOME .. "/bin/dvd-random-wall.sh"))
hl.bind(M .. " + O", function() hl.plugin.scrolloverview.overview("toggle") end)

-- ===== user apps =====
hl.bind(SM .. " + C", hl.dsp.exec_cmd("code"))
hl.bind(SM .. " + T", hl.dsp.exec_cmd("telegram-desktop"))
hl.bind(SM .. " + O", hl.dsp.exec_cmd("obs"))

-- ===== media / volume / brightness (locked = active on lockscreen) =====
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("sh " .. HOME .. "/bin/volume.sh --device output --action increase"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("sh " .. HOME .. "/bin/volume.sh --device output --action decrease"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("sh " .. HOME .. "/bin/volume.sh --device output --action toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("sh " .. HOME .. "/bin/volume.sh --device input --action toggle"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl stop"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("sh " .. HOME .. "/bin/brightness.sh --up"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("sh " .. HOME .. "/bin/brightness.sh --down"), { locked = true, repeating = true })

-- ===== session / window =====
hl.bind(M .. " + Delete", hl.dsp.exit())
hl.bind("CTRL + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(M .. " + Q", hl.dsp.window.close())
hl.bind(M .. " + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind("ALT + Return", hl.dsp.window.fullscreen())

-- ===== focus =====
hl.bind(M .. " + Right", hl.dsp.focus({ direction = "right" }))
hl.bind(M .. " + Left",  hl.dsp.focus({ direction = "left" }))
hl.bind(M .. " + Up",    hl.dsp.focus({ direction = "up" }))
hl.bind(M .. " + Down",  hl.dsp.focus({ direction = "down" }))
hl.bind("ALT + Tab",     hl.dsp.focus({ direction = "down" }))

-- ===== workspaces (switch + move-to), 1..10 =====
for i = 1, 10 do
  local key = tostring(i % 10)
  hl.bind(M .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(SM .. " + " .. key, hl.dsp.window.move({ workspace = i }))
end
hl.bind(M .. " + CTRL + Right", hl.dsp.focus({ workspace = "r+1" }))
hl.bind(M .. " + CTRL + Left",  hl.dsp.focus({ workspace = "r-1" }))
hl.bind(M .. " + CTRL + Down",  hl.dsp.focus({ workspace = "empty" }))
hl.bind(M .. " + mouse_down", hl.dsp.focus({ workspace = "e+10" }))
hl.bind(M .. " + mouse_up",   hl.dsp.focus({ workspace = "e-10" }))

-- ===== resize (repeating) =====
hl.bind(SM .. " + Right", hl.dsp.window.resize({ x = 30,  y = 0 }),   { repeating = true })
hl.bind(SM .. " + Left",  hl.dsp.window.resize({ x = -30, y = 0 }),   { repeating = true })
hl.bind(SM .. " + Up",    hl.dsp.window.resize({ x = 0,   y = -30 }), { repeating = true })
hl.bind(SM .. " + Down",  hl.dsp.window.resize({ x = 0,   y = 30 }),  { repeating = true })
hl.bind(M .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ===== move window around workspace =====
hl.bind(M .. " + SHIFT + CTRL + Right", hl.dsp.window.move({ direction = "right" }))
hl.bind(M .. " + SHIFT + CTRL + Left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(M .. " + SHIFT + CTRL + Up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(M .. " + SHIFT + CTRL + Down",  hl.dsp.window.move({ direction = "down" }))
hl.bind(M .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })

-- ===== special / silent workspaces =====
hl.bind(M .. " + grave", hl.dsp.workspace.toggle_special("special"))
hl.bind(M .. " + SHIFT + grave", hl.dsp.window.move({ workspace = "special:special" }))
hl.bind(M .. " + F1", hl.dsp.workspace.toggle_special("f1"))
hl.bind(M .. " + SHIFT + F1", hl.dsp.window.move({ workspace = "special:f1" }))
hl.bind(M .. " + F2", hl.dsp.workspace.toggle_special("f2"))
hl.bind(M .. " + SHIFT + F2", hl.dsp.window.move({ workspace = "special:f2" }))
hl.bind(M .. " + F3", hl.dsp.workspace.toggle_special("f3"))
hl.bind(M .. " + SHIFT + F3", hl.dsp.window.move({ workspace = "special:f3a" }))
hl.bind(M .. " + ALT + S", hl.dsp.window.move({ workspace = "special", silent = true }))
hl.bind(M .. " + ALT + S", hl.dsp.window.move({ workspace = "previous" }))
hl.bind(M .. " + S", hl.dsp.workspace.toggle_special(""))

-- ===== scrolloverview submap =====
hl.define_submap("scrolloverview", function()
  hl.bind("left",   function() hl.plugin.scrolloverview.navigate("left") end)
  hl.bind("right",  function() hl.plugin.scrolloverview.navigate("right") end)
  hl.bind("up",     function() hl.plugin.scrolloverview.navigate("up") end)
  hl.bind("down",   function() hl.plugin.scrolloverview.navigate("down") end)
  hl.bind("return", function() hl.plugin.scrolloverview.overview("select") end)
  hl.bind("escape", function() hl.plugin.scrolloverview.overview("off") end)
  hl.bind("mouse:272", function() hl.plugin.scrolloverview.overview("select") end, { mouse = true })
  hl.bind("mouse:274", function() hl.plugin.scrolloverview.window("close") end, { mouse = true })
end)

-- universal binds that keep working while inside a submap
hl.bind("ALT + 1", hl.dsp.focus({ workspace = 1 }), { submap_universal = true })
hl.bind("ALT + 2", hl.dsp.focus({ workspace = 2 }), { submap_universal = true })
hl.bind("ALT + 3", hl.dsp.focus({ workspace = 3 }), { submap_universal = true })
