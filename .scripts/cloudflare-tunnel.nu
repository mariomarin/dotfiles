#!/usr/bin/env nu
# Cloudflare Tunnel management
# Quick tunnels require no authentication

const TUNNEL_LOG = "/tmp/cloudflared-tunnel.log"


# Start quick tunnel (temporary, no DNS, no auth required)
def "main quick" [
    service: string = "ssh://localhost:22"  # Service to expose
    --background                            # Run in background
] {
    print $"🚀 Starting Cloudflare Quick Tunnel for ($service)..."

    if (which cloudflared | is-empty) {
        error make {msg: "cloudflared not found"}
    }

    if $background {
        # Background mode - detach and log to file
        ^cloudflared tunnel --url $service o+e> $TUNNEL_LOG &
        print $"📝 Tunnel running in background, logs: ($TUNNEL_LOG)"
    } else {
        # Foreground - run directly, cloudflared prints URL to stderr
        print "⏳ Waiting for tunnel URL (look for trycloudflare.com)..."
        print ""
        ^cloudflared tunnel --url $service
    }
}

# Stop running tunnel
def "main stop" [] {
    print "🛑 Stopping cloudflared tunnel..."

    let pids = (ps | where name =~ cloudflared | get pid)

    if ($pids | is-empty) {
        print "ℹ️  No running tunnel found"
        return
    }

    for pid in $pids {
        kill $pid
        print $"✅ Stopped tunnel (PID: ($pid))"
    }
}

# Show tunnel status
def "main status" [] {
    let running = (ps | where name =~ cloudflared)

    if ($running | is-empty) {
        print "❌ No tunnel running"
        return
    }

    print "✅ Tunnel is running:"
    $running | select pid cpu mem command | table

    # Try to get URL from log
    if ($TUNNEL_LOG | path expand | path exists) {
        let log_content = (open ($TUNNEL_LOG | path expand))
        let url_match = ($log_content | parse -r 'https://[a-z0-9-]+\.trycloudflare\.com')

        if ($url_match | is-not-empty) {
            let url = ($url_match | first | get capture0)
            print $""
            print $"🔗 Tunnel URL: ($url)"
        }
    }
}

# SSH service shortcut
def "main ssh" [
    --port: int = 22              # SSH port
    --background                  # Run in background
] {
    main quick $"ssh://localhost:($port)" --background=$background
}

# HTTP service shortcut
def "main http" [
    port: int = 8080              # HTTP port
    --background                  # Run in background
] {
    main quick $"http://localhost:($port)" --background=$background
}

# Show help / default
def main [] {
    print "Cloudflare Quick Tunnels (temporary, anonymous, no auth required)"
    print ""
    print "Commands:"
    print "  quick <service>       Start tunnel (default: ssh://localhost:22)"
    print "  ssh [--port 22]       SSH tunnel shortcut"
    print "  http <port>           HTTP tunnel shortcut"
    print "  status                Show running tunnel process"
    print "  stop                  Stop running tunnel"
    print ""
    print "Examples:"
    print "  just tunnel-ssh                    # SSH on port 22"
    print "  just tunnel-http 3000              # HTTP on port 3000"
    print "  just tunnel-quick tcp://localhost:5432  # PostgreSQL"
}
