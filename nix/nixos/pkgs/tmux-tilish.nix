# tmux-tilish - i3wm-style keybindings for tmux
# Fork with copilot auto-suggestion support
{ fetchFromGitHub, tmuxPlugins }:

tmuxPlugins.mkTmuxPlugin {
  pluginName = "tmux-tilish";
  rtpFilePath = "tilish.tmux";
  version = "unstable-2025-12-23";
  src = fetchFromGitHub {
    owner = "farzadmf";
    repo = "tmux-tilish";
    rev = "05da91dc76673cbbc28c3348be9f9ce58a68a7d9";
    hash = "sha256-74I10yM0woshdx1jLZSVR2uekC+peNsLNtOpKn/l4PE=";
  };
}
