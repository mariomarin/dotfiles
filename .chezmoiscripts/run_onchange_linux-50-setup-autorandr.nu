#!/usr/bin/env nu
# Setup autorandr for automatic display configuration (Linux desktop)

print "Setting up autorandr..."

# Create initial profile if displays are connected
if (which autorandr | is-not-empty) {
    # Save current configuration as 'default'
    let current = (autorandr | complete)
    if not ($current.stdout | str contains "default (current)") {
        print "Saving current display configuration as 'default' profile..."
        autorandr --save default | ignore
    }

    # Detect connected displays
    autorandr --change

    print "✓ Autorandr configured"
    print "  - List profiles: autorandr"
    print "  - Save profile: autorandr --save <name>"
    print "  - Change profile: autorandr <name>"
} else {
    print "⚠️  autorandr not found, skipping setup"
}
