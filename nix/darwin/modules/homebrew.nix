_:

{
  homebrew = {
    enable = true;
    # No onActivation.cleanup: brew bundle --cleanup now requires --force

    # Only apps not available in nixpkgs or better via homebrew on macOS
    # NOTE: Karabiner-DriverKit-VirtualHIDDevice installed separately for kanata
    # (full karabiner-elements conflicts with kanata - grabs keyboard exclusively)
    casks = [
      "bruno" # API testing GUI - nixpkgs version uses EOL electron
      "docker-desktop"
      "firefox" # Better macOS integration via homebrew
      "macfuse" # Mount Linux filesystems (ext4, etc.) on macOS
    ];
  };
}
