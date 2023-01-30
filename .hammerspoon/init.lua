require("caffeine")

-- TODO(harry):
-- Fix Slack keyboard shortcuts: https://github.com/STRML/init/blob/master/hammerspoon/init.lua#L197

hs.alert.show("Config loaded")

function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
-- hs.pathwatcher.new(os.getenv("HOME") .. "/dotfiles/.hammerspoon/", reloadConfig):start()


---- App switcher (Slate replacement)

-- Source: https://gist.github.com/apesic/d840d8eaba759ac143c7b8fea9475f7a
local mash_app = {"ctrl", "cmd"}

hs.hotkey.bind(mash_app, 'P', function() hs.application.launchOrFocus('1Password') end)
hs.hotkey.bind(mash_app, 'C', function() hs.application.launchOrFocus('Google Chrome') end)
hs.hotkey.bind(mash_app, 'G', function() hs.application.launchOrFocus('Google Meet') end)
hs.hotkey.bind(mash_app, 'S', function() hs.application.launchOrFocus('Slack') end)
hs.hotkey.bind(mash_app, 'T', function() hs.application.launchOrFocus('iTerm') end)
hs.hotkey.bind(mash_app, 'W', function() hs.application.launchOrFocus('WhatsApp') end)
hs.hotkey.bind(mash_app, 'Z', function() hs.application.launchOrFocus('zoom.us') end)
-- For some unknown reason `launchOrFocus` doesn't work with my Emacs setup.
-- Cf https://github.com/Hammerspoon/hammerspoon/issues/288
hs.hotkey.bind(mash_app, 'M', function() hs.application.open('Emacs'):mainWindow():focus() end)


---- Window movement (SizeUp replacement)

local mash = {"ctrl", "alt", "cmd"}

hs.window.animationDuration = 0

-- Source: https://github.com/AaronLasseigne/dotfiles/blob/50d2325c1ad7552ea95a313fbf022004e2932ce9/.hammerspoon/init.lua
local positions = {
  maximized = hs.layout.maximized,
  centered = {x=0.25, y=0, w=0.5, h=1},

  left34 = {x=0, y=0, w=0.34, h=1},
  left50 = hs.layout.left50,
  left66 = {x=0, y=0, w=0.66, h=1},
  left70 = hs.layout.left70,

  right30 = hs.layout.right30,
  right34 = {x=0.66, y=0, w=0.34, h=1},
  right50 = hs.layout.right50,
  right66 = {x=0.34, y=0, w=0.66, h=1},

  upper50 = {x=0, y=0, w=1, h=0.5},
  upper50Left50 = {x=0, y=0, w=0.5, h=0.5},
  upper50Right15 = {x=0.85, y=0, w=0.15, h=0.5},
  upper50Right30 = {x=0.7, y=0, w=0.3, h=0.5},
  upper50Right50 = {x=0.5, y=0, w=0.5, h=0.5},

  lower50 = {x=0, y=0.5, w=1, h=0.5},
  lower50Left50 = {x=0, y=0.5, w=0.5, h=0.5},
  lower50Right50 = {x=0.5, y=0.5, w=0.5, h=0.5},

  chat = {x=0.5, y=0, w=0.35, h=0.5}
}

local grid = {
  {key="f", units={positions.upper50Left50}},
  {key="g", units={positions.upper50}},
  {key="c", units={positions.upper50Right50}},

  {key="d", units={positions.left50, positions.left66, positions.left34}},
  {key="h", units={positions.maximized, positions.centered}},
  {key="t", units={positions.right50, positions.right66, positions.right34}},

  {key="b", units={positions.lower50Left50}},
  {key="m", units={positions.lower50}},
  {key="w", units={positions.lower50Right50}}
}

hs.fnutils.each(grid, function(entry)
  hs.hotkey.bind(mash, entry.key, function()
    local units = entry.units
    local screen = hs.screen.mainScreen()
    local window = hs.window.focusedWindow()
    local windowGeo = window:frame()

    local index = 0
    print("binding", units, screen, windowGeo)
    hs.fnutils.find(units, function(unit)
      index = index + 1

      local geo = hs.geometry.new(unit):fromUnitRect(screen:frame()):floor()
      print("geo", geo)
      return windowGeo:equals(geo)
    end)
    if index == #units then index = 0 end

    currentLayout = null
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
  print("switchLayout", hs.inspect.inspect(screens))
  local layout
  local layoutName
  if #screens == 1 then
    local laptop = "Color LCD"
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
  elseif screens[1]:name() == "Thunderbolt Display" or startsWith(screens[1]:name(), "LG UltraFine") then
    -- TODO: Sort screens properly by x-index:
    local leftMonitor = hs.screen.allScreens()[1]
    local rightMonitor = hs.screen.allScreens()[3]
    layout = {
      {"Emacs", nil, rightMonitor, hs.layout.maximized, nil, nil},
      {"Google Chrome", nil, leftMonitor, hs.layout.right50, nil, nil},
      {"Google Meet", nil, leftMonitor, positions.upper50Left50, nil, nil},
      {"iTerm2", nil, leftMonitor, hs.layout.left50, nil, nil},
      {"Messages", nil, leftMonitor, positions.left34, nil, nil},
      {"Slack", nil, leftMonitor, hs.layout.left50, nil, nil},
      {"WhatsApp", nil, leftMonitor, hs.layout.left50, nil, nil},
      {"zoom.us", nil, leftMonitor, positions.upper50Left50, nil, nil},
    }
    layoutName = "Dual monitor layout"
  end
  hs.layout.apply(layout)
  hs.alert.show(layoutName)
end

hs.hotkey.bind(mash, "r", function() switchLayout() end)


---- GTD task taker

-- Source: https://github.com/Hammerspoon/hammerspoon/issues/782
local chooser = nil

local commands = {
  {
    ['text'] = 'Add TODO',
    ['subText'] = 'Append to inbox.org',
    ['command'] = 'append',
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

local function append(text)
  print("append", text)
  -- TODO(harry)
  local f = io.open(os.getenv("HOME") .. "/Dropbox/notes/inbox.org", "a")
  f:write("\n** TODO " .. text)
  f:close()
end

local function choiceCallback(choice)
  if choice.command == 'append' then
    append(chooser:query())
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


---- Hyperdock / Zooom2 replacement

-- Install with `git clone https://github.com/dbalatero/SkyRocket.spoon.git ~/.hammerspoon/Spoons/SkyRocket.spoon`
local SkyRocket = hs.loadSpoon("SkyRocket")

sky = SkyRocket:new({
  -- Which modifiers to hold to move a window?
  moveModifiers = {'cmd', 'shift'},

  -- Which modifiers to hold to resize a window?
  resizeModifiers = {'alt', 'shift'},
})
