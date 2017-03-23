-- CP'ed from https://github.com/mikejquinn/dotfiles/blob/master/hammerspoon/keybindings.lua

local application = require "hs.application"
local eventtap = require "hs.eventtap"
local keycodes = require "hs.keycodes"
local hotkey = require "hs.hotkey"
local log = hs.logger.new("init", "debug")

local keyDown = eventtap.event.types.keyDown
local keyUp = eventtap.event.types.keyUp
local flagsChanged = eventtap.event.types.flagsChanged

local hyper = hs.hotkey.modal.new({}, "F18")

local module = {}

module.keys = {
  leftShift = 56,
  rightShift = 60,
  ctrl = 59,
  leftCmd = 55,
  rightCmd = 54,
}

local keyToMod = {}
keyToMod[56] = 'shift'
keyToMod[60] = 'shift'
keyToMod[59] = 'ctrl'
keyToMod[55] = 'cmd'
keyToMod[54] = 'cmd'

-- local function pressedHyper()
--    hyper.triggered = false
--    hyper:enter()
-- end

-- local function releasedHyper()
--    hyper:exit()
-- end

-- -- I have F19 bound to left ctrl key using Karabiner
-- hs.hotkey.bind({}, 'F19', pressedHyper, releasedHyper)

local function down(mods, key) return eventtap.event.newKeyEvent(mods, key, true) end
local function up(mods, key) return eventtap.event.newKeyEvent(mods, key, false) end

local emacsBlacklist = {
   'Emacs',
   'iTerm2'
}

local function emacsModeEnabled()
   local app = application.frontmostApplication():title()
   for i, appName in ipairs(emacsBlacklist) do
      if appName == app then
         return false
      end
   end
   return true
end

local function checkFlagsWithModArray(flags, mods)
   local flagCount = 0
   for _ in pairs(flags) do flagCount = flagCount + 1 end
   if flagCount ~= #mods then
      return false
   end
   for i, mod in ipairs(mods) do
      if flags[mod] ~= true then
         return false
      end
   end
   return true
end

local bindings = {}

module.__bindingevent = eventtap.new({keyDown, keyUp, flagsChanged}, function(event)
  local key = keycodes.map[event:getKeyCode()]
  local flags = event:getFlags()
  local binding = bindings[key]
  local eventType = eventtap.event.types[event:getType()]
  if eventType == "flagsChanged" then
     return false
  end
  if binding == nil then
     return false
  end
  if not checkFlagsWithModArray(flags, binding.mods) then
     return false
  end
  if binding.emacsMode and not emacsModeEnabled() then
     return false
  end
  if eventType == "keyDown" then
     return true, {down(binding.map[1], binding.map[2])}
  else
     return true, {up(binding.map[1], binding.map[2])}
  end
end)

module.__bindingevent:start()

function module.new(key, mods, mappedKey, mappedMods, emacsMode)
   bindings[key] = {mods=mods, map={mappedMods, mappedKey}, emacsMode = emacsMode}
end

local function keyCode(key, modifiers)
  modifiers = modifiers or {}
  return function() hs.eventtap.keyStroke(modifiers, key) end
end

local function eventHasMod(event, mod)
   return (event:getFlags()[mod] == true)
end

local function oneTapMetaBinding(oldKeyCode, newKeyMod, newKeyCode)
   local pressed = false
   local startTime = nil
   local tap = eventtap.new({keyDown, keyUp, flagsChanged}, function(event)
      local eventType = eventtap.event.types[event:getType()]
      -- I'm not sure why, but we have to listen for the keyUp event and pass it through or hammerspoon gets confused.
      if eventType == "keyUp" then
         return false
      end
      local keyCode = event:getKeyCode()
      if keyCode ~= oldKeyCode then
         pressed = false
         return false
      end
      if eventHasMod(event, keyToMod[oldKeyCode]) then
         pressed = true
         startTime = timer.secondsSinceEpoch()
         return false
      end
      if not pressed then
         return false
      end
      -- Don't fire the binding if the user held the meta key down for a while.
      if timer.secondsSinceEpoch() - startTime > 0.25 then
         return true, {}
      end
      -- If we reach here, the modifier key has been pressed and released without
      -- any other keys being pressed
      local down = eventtap.event.newKeyEvent(newKeyMod, newKeyCode, true)
      local up = eventtap.event.newKeyEvent(newKeyMod, newKeyCode, false)
      return true, {down, up}
   end)
   tap:start()
   return tap
end

module.__oneTapMetaBindings = {}

-- TODO: combine these two functions
function module.newOneTapMetaBinding(key, newKeyMod, newKey)
   local event = oneTapMetaBinding(key, newKeyMod, newKey)
   module.__oneTapMetaBindings[#module.__oneTapMetaBindings+1] = event
end

local function oneTapKeyBinding(oldKeyName, newKeyMod)
   local oldKeyCode = keycodes.map[oldKeyName]
   local pressed = false
   local fired = false
   local startTime = nil
   local tap = eventtap.new({keyDown, keyUp}, function(event)
      local keyCode = event:getKeyCode()
      local eventType = eventtap.event.types[event:getType()]
      local flagCount = 0
      for _ in pairs(event:getFlags()) do flagCount = flagCount + 1 end

      if flagCount ~= 0 and keyCode == oldKeyCode then
         -- log.d("false - key pressed with modifier")
         return false
      end

      if eventType == 'keyUp' then
         if keyCode ~= oldKeyCode then
            if pressed then
               -- log.d("up - ret is pressed")
               return true, {up(newKeyMod, keycodes.map[keyCode])}
            end
            -- log.d("false - ret is not pressed")
            return false
         end
         pressed = false
         if not fired then
            -- log.d("down/up - ret key pressed without other keys")
            -- Don't fire the binding if the key has been held for a while.
            if timer.secondsSinceEpoch() - startTime > 0.25 then
               return true, {}
            end
            return true, {down({}, oldKeyName), up({}, oldKeyName)}
         end
         -- log.d("nil - suppressing key up")
         return true, {}
      end

      if eventType == 'keyDown' then
         if keyCode == oldKeyCode then
            if not pressed then
              startTime = timer.secondsSinceEpoch()
            end
            pressed = true
            fired = false
            -- log.d("nil - suppressing key down")
            return true, {}
         end
         if not pressed then
            -- log.d("false - ret is not pressed")
            return false
         end
         fired = true
         -- log.d("down - key pressed while ret is down")
         return true, {down(newKeyMod, keycodes.map[keyCode])}
      end

      -- log.d("false - fallthrough")
      return false
   end)
   tap:start()
   return tap
end

module.__oneTapBindings = {}

function module.newOneTapBinding(key, mappedMod)
   local event = oneTapKeyBinding(key, mappedMod)
   module.__oneTapBindings[#module.__oneTapBindings+1] = event
end

-- local oneTapKeys = {
--    retalt = oneTapKeyModifier("return", {'alt'})
-- }
-- keybindings = {
--    hyper = hyper,
--    oneTapBindings = oneTapBindings,
--    oneTapKeys = oneTapKeys,
--    otherBindings = otherBindings
-- }

return module
