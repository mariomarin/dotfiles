# tmux-harpoon - Quick navigation between sessions and panes
{ fetchFromGitHub, tmuxPlugins }:

tmuxPlugins.mkTmuxPlugin {
  pluginName = "tmux-harpoon";
  rtpFilePath = "harpoon.tmux";
  version = "unstable-2025-12-13";
  src = fetchFromGitHub {
    owner = "Chaitanyabsprip";
    repo = "tmux-harpoon";
    rev = "main";
    hash = "sha256-eqzf3hEaliF1t7zwZlj1YDGvn0jKdbBTgy5PoOPVMEU=";
  };
}
