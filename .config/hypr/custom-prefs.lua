-- custom-prefs.lua  (port of custom-prefs.conf)
-- Included from hyprland.lua via dofile.
--
-- meowrch REWRITES ~/.config/hypr/custom-prefs.conf (Hyprlang) on every theme
-- switch. Hyprland's Lua config can't `source` a Hyprlang file, so instead we
-- READ that file here and apply its `general {}` block. This keeps meowrch theme
-- switching working with zero changes to meowrch — on reload we re-read it.

local HOME = os.getenv("HOME")

local function apply_meowrch_prefs()
  local f = io.open(HOME .. "/.config/hypr/custom-prefs.conf", "r")
  if not f then return end
  local body = f:read("*a"); f:close()

  local g = {}
  for _, key in ipairs({ "gaps_in", "gaps_out", "border_size" }) do
    local v = body:match(key .. "%s*=%s*([%-%d]+)")
    if v then g[key] = tonumber(v) end
  end
  local layout = body:match("layout%s*=%s*(%a+)")
  if layout then g.layout = layout end
  local rob = body:match("resize_on_border%s*=%s*(%a+)")
  if rob then g.resize_on_border = (rob == "true" or rob == "yes" or rob == "on") end

  -- active border (may be a gradient: "rgb(..) rgb(..) 45deg")
  local ab = body:match("col%.active_border%s*=%s*([^\n]+)")
  if ab then
    local cols = {}
    for c in ab:gmatch("rgba?%b()") do cols[#cols + 1] = c end
    local angle = ab:match("(%d+)deg")
    if #cols > 1 then
      g.col = { active_border = { colors = cols, angle = tonumber(angle) or 0 } }
    elseif #cols == 1 then
      g.col = { active_border = cols[1] }
    end
  end
  local ib = body:match("col%.inactive_border%s*=%s*(rgba?%b())")
  if ib then g.col = g.col or {}; g.col.inactive_border = ib end

  if next(g) then hl.config({ general = g }) end
end

apply_meowrch_prefs()
