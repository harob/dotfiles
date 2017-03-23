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
hs.pathwatcher.new(os.getenv("HOME") .. "/dotfiles/.hammerspoon/", reloadConfig):start()


---- Essential key remaps (Karabiner replacement)

keybindings = require "keybindings"

keybindings.newOneTapMetaBinding(keybindings.keys.leftShift, {'shift'}, '9')
keybindings.newOneTapMetaBinding(keybindings.keys.rightShift, {'shift'}, '0')
keybindings.newOneTapMetaBinding(keybindings.keys.ctrl, {}, 'escape')

keybindings.new("h", {"ctrl"}, "delete", {}, true)
-- C-w should work out-the-box in all OSX apps, but for some reason it doesn't in google docs, so remap it:
keybindings.new("w", {"ctrl"}, "delete", {"alt"}, true)


---- Vim mode (Karabiner's ubiquitous-vim replacement)

require("vim")
keybindings.newOneTapMetaBinding(keybindings.keys.rightCmd, {'ctrl'}, '[')


---- App switcher (Slate replacement)

-- Source: https://gist.github.com/apesic/d840d8eaba759ac143c7b8fea9475f7a
local mash_app = {"ctrl", "cmd"}

hs.hotkey.bind(mash_app, 'C', function() hs.application.launchOrFocus('Google Chrome') end)
hs.hotkey.bind(mash_app, 'M', function() hs.application.launchOrFocus('Emacs') end)
hs.hotkey.bind(mash_app, 'T', function() hs.application.launchOrFocus('iTerm') end)
hs.hotkey.bind(mash_app, 'H', function() hs.application.launchOrFocus('iTerm') end)
hs.hotkey.bind(mash_app, 'S', function() hs.application.launchOrFocus('Slack') end)


---- Window movement (SizeUp replacement)

local mash = {"ctrl", "alt", "cmd"}

hs.window.animationDuration = 0

-- Source: https://github.com/AaronLasseigne/dotfiles/blob/50d2325c1ad7552ea95a313fbf022004e2932ce9/.hammerspoon/init.lua
local positions = {
  maximized = hs.layout.maximized,
  centered = {x=0.15, y=0.15, w=0.7, h=0.7},

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

-- TODO(harry) The rotation between the various units doesn't work on an MBP screen
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
    hs.fnutils.find(units, function(unit)
      index = index + 1

      local geo = hs.geometry.new(unit):fromUnitRect(screen:frame()):floor()
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

-- Source: https://gist.github.com/apesic/d840d8eaba759ac143c7b8fea9475f7a
function switchLayout()
  local screens = hs.screen.allScreens()
  print("switchLayout", hs.inspect.inspect(screens))
  local layout
  local layoutName
  if #screens == 1 then
    local laptop = "Color LCD"
    layout = {
      {"iTerm2", nil, laptop, hs.layout.maximized, nil, nil},
      {"iTerm-ssh", nil, laptop, hs.layout.maximized, nil, nil},
      {"Slack", nil, laptop, hs.layout.maximized, nil, nil},
      {"Google Chrome", nil, laptop, hs.layout.maximized, nil, nil},
      {"Emacs", nil, laptop, hs.layout.maximized, nil, nil},
    }
    layoutName = "Laptop layout"
  elseif screens[1]:name() == "Thunderbolt Display" or screens[1]:name() == "LG UltraFine" then
    -- TODO: Sort screens properly by x-index:
    local leftTB = hs.screen.allScreens()[3]
    local rightTB = hs.screen.allScreens()[1]
    layout = {
      {"iTerm2", nil, leftTB, hs.layout.left50, nil, nil},
      {"iTerm-ssh", nil, leftTB, hs.layout.left50, nil, nil},
      {"Slack", nil, leftTB, hs.layout.left50, nil, nil},
      {"Google Chrome", nil, leftTB, hs.layout.right50, nil, nil},
      {"Emacs", nil, rightTB, hs.layout.maximized, nil, nil},
    }
    layoutName = "Thunderbolt layout"
  end
  hs.layout.apply(layout)
  hs.alert.show(layoutName)
end

hs.hotkey.bind(mash, "r", function() switchLayout() end)
hs.hotkey.bind(mash, "p", function() switchLayout() end)
hs.hotkey.bind(mash, "o", function() switchLayout() end)

local lastNumberOfScreens = #hs.screen.allScreens()

function onScreensChanged()
  local numScreens = #hs.screen.allScreens()

  if lastNumberOfScreens ~= numScreens then
    switchLayout()
    lastNumberOfScreens = numScreens
  end
end

local screenWatcher = hs.screen.watcher.new(onScreensChanged)
screenWatcher:start()


---- GTD task taker

-- Source: https://github.com/Hammerspoon/hammerspoon/issues/782
local chooser = nil

local commands = {
  {
    ['text'] = 'Add TODO',
    ['subText'] = 'Prepend to inbox.org',
    ['command'] = 'prepend',
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

local function prependCallbackFn (exitCode, stdOut, stdErr)
  if exitCode > 0 then
    print("Prepend failure", exitCode, stdOut, stdErr)
  end
end

local function prepend(text)
  print("prepend", text)
  -- sed -i '1i Text to prepend' file.txt
  hs.task.new("/usr/local/bin/gsed",
              prependCallbackFn,
              {"-i", "1i ** TODO " .. text .. "", os.getenv("HOME") .. "/Dropbox/notes/inbox.org"}
  ):start()
end

local function choiceCallback(choice)
  if choice.command == 'prepend' then
    prepend(chooser:query())
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
