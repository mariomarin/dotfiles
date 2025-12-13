#!/usr/bin/env nu
# Cloudflare Tunnel management with cf-vault
# Uses cf-vault for credential management and Cloudflare API for tunnel queries

const TUNNEL_LOG = "/tmp/cloudflared-tunnel.log"
const CF_API = "https://api.cloudflare.com/client/v4"

# List active tunnels via Cloudflare API
export def "tunnel list" [
    --profile: string = "cloudflare"  # cf-vault profile name
] {
    # Get account ID from environment
    let account_id = $env.CF_ACCOUNT_ID? | default ""
    if ($account_id | is-empty) {
        error make {msg: "CF_ACCOUNT_ID not set. Export it or add to cf-vault profile"}
    }

    # Query API via cf-vault
    let response = (
        cf-vault exec $profile -- curl -s $"($CF_API)/accounts/($account_id)/tunnels?is_deleted=false"
        | from json
    )

    if ($response.success? | default false) {
        $response.result | select id name status created_at | table
    } else {
        print $"❌ API error: ($response.errors)"
    }
}

# Start quick tunnel (temporary, no DNS)
export def "tunnel quick" [
    service: string = "ssh://localhost:22"  # Service to expose
    --background                            # Run in background
] {
    print $"🚀 Starting Cloudflare Quick Tunnel for ($service)..."

    if (which cloudflared | is-empty) {
        error make {msg: "cloudflared not found"}
    }

    # Start tunnel process
    let process = if $background {
        # Background mode - detach and log to file
        ^cloudflared tunnel --url $service o+e>| tee $TUNNEL_LOG | complete
        print $"📝 Tunnel running in background, logs: ($TUNNEL_LOG)"
        null
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

# Setup cf-vault profile for Cloudflare
export def "tunnel setup" [
    --profile: string = "cloudflare"  # Profile name
] {
    print "🔧 Setting up cf-vault profile for Cloudflare..."
    print ""
    print "You'll need:"
    print "  1. Cloudflare API token (from dash.cloudflare.com)"
    print "  2. Account ID (from Cloudflare dashboard)"
    print ""

    if (which cf-vault | is-empty) {
        error make {msg: "cf-vault not found. Install it first."}
    }

    # Add profile
    ^cf-vault add $profile

    print ""
    print $"✅ Profile '($profile)' created"
    print "💡 Set CF_ACCOUNT_ID in your shell config:"
    print $"   export CF_ACCOUNT_ID='your-account-id'"
}

# Show help
export def "tunnel help" [] {
    print "Cloudflare Tunnel with cf-vault"
    print ""
    print "Setup:"
    print "  tunnel setup              Setup cf-vault profile"
    print ""
    print "Quick tunnels (temporary):"
    print "  tunnel quick <service>    Start quick tunnel (default: ssh://localhost:22)"
    print "  tunnel ssh [--port 22]    SSH tunnel shortcut"
    print "  tunnel http <port>        HTTP tunnel shortcut"
    print ""
    print "Management:"
    print "  tunnel list               List active tunnels via API"
    print "  tunnel status             Show running tunnel process"
    print "  tunnel stop               Stop running tunnel"
    print ""
    print "Examples:"
    print "  tunnel setup              # First-time setup"
    print "  tunnel ssh                # Quick SSH tunnel on port 22"
    print "  tunnel http 3000          # HTTP server on port 3000"
    print "  tunnel list               # Query active tunnels"
}

# Default
def main [] {
    tunnel help
}
