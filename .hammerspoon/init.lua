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

hs.hotkey.bind(mash_app, 'C', function() hs.application.launchOrFocus('Google Chrome') end)
hs.hotkey.bind(mash_app, 'G', function() hs.application.launchOrFocus('Google Meet') end)
hs.hotkey.bind(mash_app, 'P', function() hs.application.launchOrFocus('Preview') end)
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

-- Inspired by Linux alt-drag or Better Touch Tools move/resize functionality
-- from https://gist.github.com/kizzx2/e542fa74b80b7563045a
-- Command-shift-move: move window under mouse
-- Alt-Shift-move: resize window under mouse

-- TODO(harry) This is super laggy under Catalina, so I'm turning this off for now.

-- function get_window_under_mouse()
--    local my_pos = hs.geometry.new(hs.mouse.getAbsolutePosition())
--    local my_screen = hs.mouse.getCurrentScreen()
--    return hs.fnutils.find(hs.window.orderedWindows(), function(w)
--                              return my_screen == w:screen() and
--                                 w:isStandard() and
--                                 (not w:isFullScreen()) and
--                                 my_pos:inside(w:frame())
--    end)
-- end

-- dragging = {}                   -- global variable to hold the dragging/resizing state

-- drag_event = hs.eventtap.new({ hs.eventtap.event.types.mouseMoved }, function(e)
--       if not dragging then return nil end
--       if dragging.mode==3 then -- just move
--          local dx = e:getProperty(hs.eventtap.event.properties.mouseEventDeltaX)
--          local dy = e:getProperty(hs.eventtap.event.properties.mouseEventDeltaY)
--          dragging.win:move({dx, dy}, nil, false, 0)
--       else -- resize
--          local pos=hs.mouse.getAbsolutePosition()
--          local w1 = dragging.size.w + (pos.x-dragging.off.x)
--          local h1 = dragging.size.h + (pos.y-dragging.off.y)
--          dragging.win:setSize(w1, h1)
--       end
-- end)

-- flags_event = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function(e)
--       local flags = e:getFlags()
--       local mode=(flags.shift and 1 or 0) + (flags.cmd and 2 or 0) + (flags.alt and 4 or 0)
--       if mode==3 or mode==5 then -- valid modes
--          if dragging then
--             if dragging.mode == mode then return nil end -- already working
--          else
--             -- only update window if we hadn't started dragging/resizing already
--             dragging={win = get_window_under_mouse()}
--             if not dragging.win then -- no good window
--                dragging=nil
--                return nil
--             end
--          end
--          dragging.mode = mode   -- 3=drag, 5=resize
--          if mode==5 then
--             dragging.off=hs.mouse.getAbsolutePosition()
--             dragging.size=dragging.win:size()
--          end
--          drag_event:start()
--       else                      -- not a valid mode
--          if dragging then
--             drag_event:stop()
--             dragging = nil
--          end
--       end
--       return nil
-- end)
-- flags_event:start()
