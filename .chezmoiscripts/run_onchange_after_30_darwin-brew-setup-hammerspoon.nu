#!/usr/bin/env nu
# Setup Hammerspoon to launch at login and use XDG config path

# Check if Hammerspoon is installed
if not (which hs | is-not-empty) and not ("/Applications/Hammerspoon.app" | path exists) {
    print "Hammerspoon not installed, skipping setup"
    exit 0
}

print "Configuring Hammerspoon..."

# Configure Hammerspoon to use XDG config path
print "  Setting config path to ~/.config/hammerspoon/init.lua"
defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"

print "  Adding to login items..."

# Use osascript to add to login items
let result = (do {
    osascript -e '
tell application "System Events"
    -- Remove existing login item if present
    set loginItems to get the name of every login item
    if loginItems contains "Hammerspoon" then
        delete login item "Hammerspoon"
    end if

    -- Add new login item
    make login item at end with properties {path:"/Applications/Hammerspoon.app", hidden:false}
end tell
'
} | complete)

if $result.exit_code == 0 {
    print "✓ Hammerspoon configured to launch at login"
    print "  Launch now with: open -a Hammerspoon"
} else {
    print "⚠ Could not auto-add to login items (needs Automation permission)"
    print "  Add manually: System Settings > General > Login Items"
    print "  Or grant permission and run: chezmoi apply"
}
