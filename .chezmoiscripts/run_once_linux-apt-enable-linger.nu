#!/usr/bin/env nu
# Enable systemd user session lingering
# This allows systemd --user to start at boot without login

let linger_enabled = (
    loginctl show-user $env.USER
    | lines
    | parse "{key}={value}"
    | where key == "Linger"
    | get value.0?
    | default "no"
) == "yes"

if $linger_enabled {
    exit 0
}

sudo loginctl enable-linger $env.USER
