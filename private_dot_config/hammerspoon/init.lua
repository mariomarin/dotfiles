-- Hammerspoon - Workspace management for macOS
-- Integrates with Kanata window layer (= key → Ctrl+Alt)
-- Matches LeftWM keybindings: =+1-9 for spaces, =+h/l for navigation

-- Reload config automatically
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", function(files)
  for _, file in pairs(files) do
    if file:match("%.lua$") then
      hs.reload()
      return
    end
  end
end):start()

hs.alert.show("Hammerspoon loaded")

-- Helper: Get all spaces for a screen
local function getSpacesForScreen(screen)
  local allSpaces = hs.spaces.allSpaces()
  local screenUUID = screen:getUUID()
  return allSpaces[screenUUID] or {}
end

-- Helper: Get current space ID
local function getCurrentSpace()
  return hs.spaces.focusedSpace()
end

-- Helper: Get space index (1-based) for a space ID
local function getSpaceIndex(spaceID)
  local screen = hs.screen.mainScreen()
  local spaces = getSpacesForScreen(screen)
  for i, id in ipairs(spaces) do
    if id == spaceID then
      return i
    end
  end
  return nil
end

-- Switch to workspace by number (Ctrl+Alt+1-9)
for i = 1, 9 do
  hs.hotkey.bind({"ctrl", "alt"}, tostring(i), function()
    local screen = hs.screen.mainScreen()
    local spaces = getSpacesForScreen(screen)

    if spaces[i] then
      hs.spaces.gotoSpace(spaces[i])
    else
      hs.alert.show("Desktop " .. i .. " does not exist")
    end
  end)
end

-- Move window to workspace (Ctrl+Alt+Shift+1-9)
for i = 1, 9 do
  hs.hotkey.bind({"ctrl", "alt", "shift"}, tostring(i), function()
    local win = hs.window.focusedWindow()
    if not win then
      hs.alert.show("No focused window")
      return
    end

    local screen = win:screen()
    local spaces = getSpacesForScreen(screen)

    if spaces[i] then
      hs.spaces.moveWindowToSpace(win, spaces[i])
      hs.spaces.gotoSpace(spaces[i])  -- Follow window
    else
      hs.alert.show("Desktop " .. i .. " does not exist")
    end
  end)
end

-- Navigate to previous space (Ctrl+Alt+h)
hs.hotkey.bind({"ctrl", "alt"}, "h", function()
  local currentSpace = getCurrentSpace()
  local currentIndex = getSpaceIndex(currentSpace)

  if currentIndex and currentIndex > 1 then
    local screen = hs.screen.mainScreen()
    local spaces = getSpacesForScreen(screen)
    hs.spaces.gotoSpace(spaces[currentIndex - 1])
  else
    -- Wrap around to last space
    local screen = hs.screen.mainScreen()
    local spaces = getSpacesForScreen(screen)
    hs.spaces.gotoSpace(spaces[#spaces])
  end
end)

-- Navigate to next space (Ctrl+Alt+l)
hs.hotkey.bind({"ctrl", "alt"}, "l", function()
  local currentSpace = getCurrentSpace()
  local currentIndex = getSpaceIndex(currentSpace)
  local screen = hs.screen.mainScreen()
  local spaces = getSpacesForScreen(screen)

  if currentIndex and currentIndex < #spaces then
    hs.spaces.gotoSpace(spaces[currentIndex + 1])
  else
    -- Wrap around to first space
    hs.spaces.gotoSpace(spaces[1])
  end
end)

-- Focus window below (Ctrl+Alt+j)
hs.hotkey.bind({"ctrl", "alt"}, "j", function()
  local win = hs.window.focusedWindow()
  if win then
    local nextWin = win:focusWindowSouth(nil, true, true)
    if not nextWin then
      -- Wrap around: focus first window
      local allWins = hs.window.orderedWindows()
      if #allWins > 1 then
        allWins[2]:focus()  -- Skip current window
      end
    end
  end
end)

-- Focus window above (Ctrl+Alt+k)
hs.hotkey.bind({"ctrl", "alt"}, "k", function()
  local win = hs.window.focusedWindow()
  if win then
    local nextWin = win:focusWindowNorth(nil, true, true)
    if not nextWin then
      -- Wrap around: focus last window
      local allWins = hs.window.orderedWindows()
      if #allWins > 1 then
        allWins[#allWins]:focus()
      end
    end
  end
end)

-- Swap spaces between monitors (Ctrl+Alt+w)
-- Useful when you connect/disconnect external monitor
hs.hotkey.bind({"ctrl", "alt"}, "w", function()
  local screens = hs.screen.allScreens()

  if #screens < 2 then
    hs.alert.show("Only one monitor detected")
    return
  end

  -- Get current space on each screen
  local space1 = hs.spaces.activeSpaceOnScreen(screens[1])
  local space2 = hs.spaces.activeSpaceOnScreen(screens[2])

  -- Get windows in each space
  local wins1 = hs.fnutils.filter(hs.window.allWindows(), function(win)
    return hs.fnutils.contains(hs.spaces.windowSpaces(win), space1)
  end)

  local wins2 = hs.fnutils.filter(hs.window.allWindows(), function(win)
    return hs.fnutils.contains(hs.spaces.windowSpaces(win), space2)
  end)

  -- Move windows to opposite screen
  for _, win in ipairs(wins1) do
    win:moveToScreen(screens[2])
  end

  for _, win in ipairs(wins2) do
    win:moveToScreen(screens[1])
  end

  hs.alert.show("Swapped workspaces between monitors")
end)

-- Move window to previous monitor (Ctrl+Alt+Shift+comma)
hs.hotkey.bind({"ctrl", "alt", "shift"}, ",", function()
  local win = hs.window.focusedWindow()
  if win then
    local screen = win:screen()
    local prevScreen = screen:previous()
    win:moveToScreen(prevScreen)
    hs.alert.show("Moved to " .. prevScreen:name())
  end
end)

-- Move window to next monitor (Ctrl+Alt+Shift+period)
hs.hotkey.bind({"ctrl", "alt", "shift"}, ".", function()
  local win = hs.window.focusedWindow()
  if win then
    local screen = win:screen()
    local nextScreen = screen:next()
    win:moveToScreen(nextScreen)
    hs.alert.show("Moved to " .. nextScreen:name())
  end
end)

-- Debug: Show current space info (Ctrl+Alt+i)
hs.hotkey.bind({"ctrl", "alt"}, "i", function()
  local currentSpace = getCurrentSpace()
  local currentIndex = getSpaceIndex(currentSpace)
  local screen = hs.screen.mainScreen()
  local spaces = getSpacesForScreen(screen)

  hs.alert.show(string.format(
    "Desktop %d of %d\nScreen: %s",
    currentIndex or 0,
    #spaces,
    screen:name()
  ))
end)
