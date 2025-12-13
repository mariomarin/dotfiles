#!/usr/bin/env nu
# Cloudflare Tunnel management
# Quick tunnels require no authentication

const TUNNEL_LOG = "/tmp/cloudflared-tunnel.log"

def extract-url [] {
    if not ($TUNNEL_LOG | path exists) { return null }
    open $TUNNEL_LOG
    | parse -r '(https://[a-z0-9-]+\.trycloudflare\.com)'
    | get -i 0?.capture0
}

# Get tunnel URL from log (prints export command)
def "main url" [] {
    let url = extract-url
    if ($url | is-empty) {
        print "❌ No tunnel URL found in log"
        exit 1
    }
    let host = $url | str replace "https://" ""
    print $"export CLOUDFLARE_TUNNEL_HOST=($host)"
}

# Start quick tunnel (temporary, no DNS, no auth required)
def "main quick" [
    service: string = "ssh://localhost:22"  # Service to expose
    --background                            # Run in background
] {
    print $"🚀 Starting Cloudflare Quick Tunnel for ($service)..."

    if (which cloudflared | is-empty) {
        error make {msg: "cloudflared not found"}
    }

    # Clear old log
    rm -f $TUNNEL_LOG

    if $background {
        ^cloudflared tunnel --url $service o+e> $TUNNEL_LOG &
        print $"📝 Tunnel running in background"
        print $"   Log: ($TUNNEL_LOG)"
        print $"   URL: just tunnel-url (after ~5s)"
    } else {
        # Foreground - tee to log while showing output
        print "⏳ Waiting for tunnel URL..."
        print ""
        bash -c $"cloudflared tunnel --url '($service)' 2>&1 | tee ($TUNNEL_LOG)"
    }
}

# Stop running tunnel
def "main stop" [] {
    let pids = ps | where name =~ cloudflared | get pid
    if ($pids | is-empty) {
        print "ℹ️  No tunnel running"
        return
    }
    $pids | each { |pid| kill $pid; print $"✅ Stopped (PID: ($pid))" } | ignore
    rm -f $TUNNEL_LOG
}

# Show tunnel status
def "main status" [] {
    let running = ps | where name =~ cloudflared
    if ($running | is-empty) {
        print "❌ No tunnel running"
        return
    }
    print "✅ Tunnel is running:"
    $running | select pid cpu mem command | table

    let url = extract-url
    if ($url | is-not-empty) { print $"\n🔗 ($url)" }
}

# SSH service shortcut
def "main ssh" [--port: int = 22, --background] {
    main quick $"ssh://localhost:($port)" --background=$background
}

# HTTP service shortcut
def "main http" [port: int = 8080, --background] {
    main quick $"http://localhost:($port)" --background=$background
}

# Show help / default
def main [] {
    print "Cloudflare Quick Tunnels (temporary, anonymous, no auth)"
    print ""
    print "Commands:"
    print "  ssh [--port 22]       SSH tunnel"
    print "  http <port>           HTTP tunnel"
    print "  quick <service>       Custom service (e.g. tcp://localhost:5432)"
    print "  url                   Print export command with tunnel host"
    print "  status                Show running tunnel"
    print "  stop                  Stop tunnel"
    print ""
    print "Options: --background   Run detached"
}
