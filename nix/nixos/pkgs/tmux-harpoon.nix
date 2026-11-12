# tmux-harpoon - Quick navigation between sessions and panes
{ fetchFromGitHub, tmuxPlugins }:

tmuxPlugins.mkTmuxPlugin {
  pluginName = "tmux-harpoon";
  rtpFilePath = "harpoon.tmux";
  version = "unstable-2026-03-14";
  src = fetchFromGitHub {
    owner = "Chaitanyabsprip";
    repo = "tmux-harpoon";
    rev = "b2c39f1e78f5e37ac217e146f6efa5893fadeca7";
    hash = "sha256-i2Ve3Ii9FViWnJ2GQw6dn26SrVWXlcpsCYkTum7oj3A=";
  };
}
