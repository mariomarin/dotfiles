#!/usr/bin/env nu
# Cloudflare Tunnel management
# Quick tunnels require no authentication

const TUNNEL_LOG = "/tmp/cloudflared-tunnel.log"
const CF_API = "https://api.cloudflare.com/client/v4"

# List active tunnels via Cloudflare API
export def "tunnel list" [] {
    # Requires CF_ACCOUNT_ID and CF_API_TOKEN environment variables
    let account_id = $env.CF_ACCOUNT_ID? | default ""
    let api_token = $env.CF_API_TOKEN? | default ""

    if ($account_id | is-empty) {
        print "❌ CF_ACCOUNT_ID not set"
        print "   Get it from: https://dash.cloudflare.com → Account ID"
        return
    }

    if ($api_token | is-empty) {
        print "❌ CF_API_TOKEN not set"
        print "   Create one at: https://dash.cloudflare.com/profile/api-tokens"
        print "   Required permission: Account > Cloudflare Tunnel > Read"
        return
    }

    let response = (
        http get $"($CF_API)/accounts/($account_id)/tunnels?is_deleted=false"
            --headers [Authorization $"Bearer ($api_token)"]
        | from json
    )

    if ($response.success? | default false) {
        $response.result | select id name status created_at | table
    } else {
        print $"❌ API error: ($response.errors)"
    }
}

# Start quick tunnel (temporary, no DNS, no auth required)
export def "tunnel quick" [
    service: string = "ssh://localhost:22"  # Service to expose
    --background                            # Run in background
] {
    print $"🚀 Starting Cloudflare Quick Tunnel for ($service)..."

    if (which cloudflared | is-empty) {
        error make {msg: "cloudflared not found"}
    }

    if $background {
        # Background mode - detach and log to file
        ^cloudflared tunnel --url $service o+e>| tee $TUNNEL_LOG | complete
        print $"📝 Tunnel running in background, logs: ($TUNNEL_LOG)"
    } else {
        # Foreground - stream output and parse URL
        print "⏳ Waiting for tunnel URL..."
        ^cloudflared tunnel --url $service err> | lines | each { |line|
            print $line

            # Parse URL from stderr
            let url_match = ($line | parse -r 'https://[a-z0-9-]+\.trycloudflare\.com')
            if ($url_match | is-not-empty) {
                let url = ($url_match | first | get capture0)
                print ""
                print $"✅ Tunnel URL: ($url)"
                print $"   Service: ($service)"
                print ""
            }
        }
    }
}

# Stop running tunnel
export def "tunnel stop" [] {
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
export def "tunnel status" [] {
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
export def "tunnel ssh" [
    --port: int = 22              # SSH port
    --background                  # Run in background
] {
    tunnel quick $"ssh://localhost:($port)" --background=$background
}

# HTTP service shortcut
export def "tunnel http" [
    port: int = 8080              # HTTP port
    --background                  # Run in background
] {
    tunnel quick $"http://localhost:($port)" --background=$background
}

# Show help
export def "tunnel help" [] {
    print "Cloudflare Quick Tunnels (no auth required)"
    print ""
    print "Quick tunnels (temporary, anonymous):"
    print "  tunnel quick <service>    Start quick tunnel (default: ssh://localhost:22)"
    print "  tunnel ssh [--port 22]    SSH tunnel shortcut"
    print "  tunnel http <port>        HTTP tunnel shortcut"
    print "  tunnel status             Show running tunnel process"
    print "  tunnel stop               Stop running tunnel"
    print ""
    print "API access (requires env vars):"
    print "  tunnel list               List named tunnels via API"
    print ""
    print "Environment variables for API access:"
    print "  CF_ACCOUNT_ID  → dash.cloudflare.com → Overview → Account ID (right sidebar)"
    print "  CF_API_TOKEN   → dash.cloudflare.com/profile/api-tokens → Create Token"
    print "                   Permission: Account > Cloudflare Tunnel > Read"
    print ""
    print "Examples:"
    print "  tunnel ssh                # Quick SSH tunnel on port 22"
    print "  tunnel http 3000          # HTTP server on port 3000"
    print "  tunnel quick tcp://localhost:5432  # PostgreSQL"
}

# Default
def main [] {
    tunnel help
}
