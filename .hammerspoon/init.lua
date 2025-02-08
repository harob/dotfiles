require("caffeine")


---- App switcher (Slate replacement)

-- Source: https://gist.github.com/apesic/d840d8eaba759ac143c7b8fea9475f7a
local mash_app = {"ctrl", "cmd"}

hs.hotkey.bind(mash_app, 'A', function() hs.application.launchOrFocus('Cursor') end)
hs.hotkey.bind(mash_app, 'C', function() hs.application.launchOrFocus('Google Chrome') end)
hs.hotkey.bind(mash_app, 'G', function() hs.application.launchOrFocus('Google Meet') end)
hs.hotkey.bind(mash_app, 'I', function() hs.application.launchOrFocus('Messages') end)
hs.hotkey.bind(mash_app, 'M', function() hs.application.launchOrFocus('Emacs') end)
hs.hotkey.bind(mash_app, 'S', function() hs.application.launchOrFocus('Slack') end)
hs.hotkey.bind(mash_app, 'T', function() hs.application.launchOrFocus('Ghostty') end)
hs.hotkey.bind(mash_app, 'W', function() hs.application.launchOrFocus('WhatsApp') end)
hs.hotkey.bind(mash_app, 'Z', function() hs.application.launchOrFocus('zoom.us') end)


---- Window movement (SizeUp replacement)

local mash = {"ctrl", "alt", "cmd"}

hs.window.animationDuration = 0

-- Source: https://github.com/AaronLasseigne/dotfiles/blob/50d2325c1ad7552ea95a313fbf022004e2932ce9/.hammerspoon/init.lua
local positions = {
  maximized = hs.layout.maximized,
  centered50 = {x=0.25, y=0, w=0.5, h=1},
  centered34 = {x=0.33, y=0, w=0.34, h=1},

  left33 = {x=0, y=0, w=0.33, h=1},
  left50 = hs.layout.left50,
  left67 = {x=0, y=0, w=0.67, h=1},

  right33 = {x=0.67, y=0, w=0.33, h=1},
  right50 = hs.layout.right50,
  right67 = {x=0.33, y=0, w=0.67, h=1},

  upper50 = {x=0, y=0, w=1, h=0.5},
  upper50Left50 = {x=0, y=0, w=0.5, h=0.5},
  upper50Right15 = {x=0.85, y=0, w=0.15, h=0.5},
  upper50Right30 = {x=0.7, y=0, w=0.3, h=0.5},
  upper50Right50 = {x=0.5, y=0, w=0.5, h=0.5},

  lower50 = {x=0, y=0.5, w=1, h=0.5},
  lower50Left50 = {x=0, y=0.5, w=0.5, h=0.5},
  lower50Right50 = {x=0.5, y=0.5, w=0.5, h=0.5}
}

-- This is a 3x3 grid around the right hand's anchor key in Dvorak:
local grid = {
  {key="f", units={positions.upper50Left50}},
  {key="g", units={positions.upper50}},
  {key="c", units={positions.upper50Right50}},

  {key="d", units={positions.left50, positions.left67, positions.left33}},
  {key="h", units={positions.maximized, positions.centered50, positions.centered34}},
  {key="t", units={positions.right50, positions.right67, positions.right33}},

  {key="b", units={positions.lower50Left50}},
  {key="m", units={positions.lower50}},
  {key="w", units={positions.lower50Right50}}
}

function roughlyEquals(n1, n2)
  return (n1 >= n2 - 10) and (n1 <= n2 + 10)
end

-- Adapted from hs.geometry.equals
function geoRoughlyEquals(t1, t2)
  return roughlyEquals(t1.x, t2.x) and
    roughlyEquals(t1.y, t2.y) and
    roughlyEquals(t1.w, t2.w) and
    roughlyEquals(t1.h, t2.h)
end

hs.fnutils.each(grid, function(entry)
  hs.hotkey.bind(mash, entry.key, function()
    local units = entry.units
    local screen = hs.screen.mainScreen()
    local window = hs.window.focusedWindow()
    local windowGeo = window:frame()

    local index = 0
    print("windowGeo", windowGeo)
    hs.fnutils.find(units, function(unit)
      index = index + 1

      local geo = hs.geometry.new(unit):fromUnitRect(screen:frame()):floor()
      print("consideredGeo", geo)
      -- For some reason the Emacs window is off by 5ish pixels on width and
      -- height from what you'd expect, so do some fuzzy math:
      return geoRoughlyEquals(windowGeo, geo)
    end)
    if index == #units then index = 0 end

    currentLayout = null
    print("targetGeo", units[index + 1])
    window:moveToUnit(units[index + 1])
  end)
end)

-- Source: https://gist.github.com/josephholsten/1e17c7418d9d8ec0e783
function sendWindowNextMonitor()
  hs.alert.show("Next Monitor")
  local win = hs.window.focusedWindow()
  local nextScreen = win:screen():next()
  win:moveToScreen(nextScreen)
end

hs.hotkey.bind(mash, "s", sendWindowNextMonitor)


---- Screen watcher

-- Source: https://stackoverflow.com/a/22831842
function startsWith(str, prefix)
  return string.sub(str, 1, string.len(prefix)) == prefix
end

-- Source: https://gist.github.com/apesic/d840d8eaba759ac143c7b8fea9475f7a
function switchLayout()
  local screens = hs.screen.allScreens()
  table.sort(screens, function(a, b) return a:position() < b:position() end)
  print("switchLayout", hs.inspect.inspect(screens))
  local layout
  local layoutName
  if #screens == 1 then
    local laptop = screens[1]
    layout = {
      {"Emacs", nil, laptop, hs.layout.maximized, nil, nil},
      {"Google Chrome", nil, laptop, hs.layout.maximized, nil, nil},
      {"Google Meet", nil, laptop, positions.upper50Left50, nil, nil},
      {"iTerm2", nil, laptop, hs.layout.maximized, nil, nil},
      {"Messages", nil, laptop, hs.layout.left50, nil, nil},
      {"Slack", nil, laptop, hs.layout.left50, nil, nil},
      {"WhatsApp", nil, laptop, hs.layout.left50, nil, nil},
      {"zoom.us", nil, laptop, positions.upper50Left50, nil, nil},
    }
    layoutName = "Laptop layout"
  elseif #screens == 3 then
    local leftMonitor = screens[1]
    local rightMonitor = screens[2]
    layout = {
      {"Emacs", nil, rightMonitor, hs.layout.maximized, nil, nil},
      {"Google Chrome", nil, leftMonitor, hs.layout.right50, nil, nil},
      {"Google Meet", nil, leftMonitor, positions.upper50Left50, nil, nil},
      {"iTerm2", nil, leftMonitor, hs.layout.left50, nil, nil},
      {"Messages", nil, leftMonitor, positions.left33, nil, nil},
      {"Slack", nil, leftMonitor, hs.layout.left50, nil, nil},
      {"WhatsApp", nil, leftMonitor, hs.layout.left50, nil, nil},
      {"zoom.us", nil, leftMonitor, positions.upper50Left50, nil, nil},
    }
    layoutName = "Dual monitor layout"
  end
  print("layout", layoutName)
  hs.layout.apply(layout)
  hs.alert.show(layoutName)
end

hs.hotkey.bind(mash, "r", function() switchLayout() end)


---- Hyperdock / Zooom2 replacement

-- Install with `git clone https://github.com/dbalatero/SkyRocket.spoon.git ~/.hammerspoon/Spoons/SkyRocket.spoon`
local SkyRocket = hs.loadSpoon("SkyRocket")

sky = SkyRocket:new({
  -- Which modifiers to hold to move a window?
  moveModifiers = {'cmd', 'shift'},

  -- Which modifiers to hold to resize a window?
  resizeModifiers = {'alt', 'shift'},
})


hs.alert.show("Config loaded")


---- GTD task taker

-- Source: https://github.com/Hammerspoon/hammerspoon/issues/782
local chooser = nil

local commands = {
  {
    ['text'] = 'Add TODO',
    ['subText'] = 'Append TODO to inbox.org',
    ['command'] = 'appendTodo',
  },
  {
    ['text'] = 'Add note',
    ['subText'] = 'Append note to inbox.org',
    ['command'] = 'appendNote',
  },
}

-- This resets the choices to the command table, and has the side effect
-- of resetting the highlighted choice as well.
local function resetChoices()
  chooser:rows(#commands)
  -- add commands
  local choices = {}
  for _, command in ipairs(commands) do
    choices[#choices+1] = command
  end
  chooser:choices(choices)
end

local function appendTodo(text)
  print("appendTodo ", text)
  local f = io.open(os.getenv("HOME") .. "/Dropbox/notes/inbox.org", "a")
  f:write("** TODO " .. text .. "\n")
  f:close()
end

local function appendNote(text)
  print("appendNote ", text)
  local f = io.open(os.getenv("HOME") .. "/Dropbox/notes/inbox.org", "a")
  f:write("** " .. text .. "\n")
  f:close()
end

local function choiceCallback(choice)
  local text = chooser:query()
  if choice.command == 'appendTodo' then
    appendTodo(text)
  elseif choice.command == 'appendNote' then
    appendNote(text)
  else
    print("Unknown choice!")
  end
  -- set the chooser back to the default state
  resetChoices()
  chooser:query('')
end

hs.hotkey.bind(mash_app, "space", function()
  chooser = hs.chooser.new(choiceCallback)
  -- disable built-in search
  chooser:queryChangedCallback(function() end)
  -- populate the command list
  resetChoices()
  chooser:show()
end)
