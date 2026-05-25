#!/usr/bin/env nu
# Register tridactyl-native with Firefox on macOS

def build-manifest [native_bin: string] {
  {
    name: "tridactyl"
    description: "Tridactyl native command handler"
    path: $native_bin
    type: "stdio"
    allowed_extensions: [
      "tridactyl.vim@cmcaine.co.uk"
      "tridactyl.vim.betas@cmcaine.co.uk"
      "tridactyl.vim.betas.nonewtab@cmcaine.co.uk"
    ]
  }
}

def main [] {
  let hosts_dir = $"($env.HOME)/Library/Application Support/Mozilla/NativeMessagingHosts"
  let manifest = $"($hosts_dir)/tridactyl.json"

  let native_result = (which native_main)
  if ($native_result | is-empty) { exit 0 }

  let native_bin = ($native_result | first | get path)
  let nix_manifest = ($native_bin | path dirname | path dirname | path join "lib/mozilla/native-messaging-hosts/tridactyl.json")

  if not ($nix_manifest | path exists) { exit 0 }

  mkdir $hosts_dir
  build-manifest $native_bin | to json | save -f $manifest
}
