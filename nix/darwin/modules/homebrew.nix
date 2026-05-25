_:

{
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap"; # Remove unlisted casks

    # Only apps not available in nixpkgs or better via homebrew on macOS
    # NOTE: Karabiner-DriverKit-VirtualHIDDevice installed separately for kanata
    # (full karabiner-elements conflicts with kanata - grabs keyboard exclusively)
    casks = [
      "bruno" # API testing GUI - nixpkgs version uses EOL electron
      "docker" # Docker Desktop - not in nixpkgs
      "firefox" # Better macOS integration via homebrew
      "voiceink" # Voice to text
    ];
  };
}
