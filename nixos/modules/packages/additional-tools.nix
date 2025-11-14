{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Data processing and utilities
    xan # CSV data manipulation toolkit (maintained fork of xsv)

    # Kubernetes tools
    stern # Multi pod and container log tailing
    krew # Kubernetes plugin manager

    # Network and cloud tools
    speedtest-cli # Internet speed testing
    awscli # AWS CLI v1
    aws-sso-cli # AWS SSO authentication helper

    # Development and diff tools
    jd-diff-patch # JSON diff and patch

    # Media and download tools
    yewtube # Terminal YouTube viewer
    yt-dlp # YouTube downloader

    # Git utilities
    git-branchless # Git workflow for trunk-based development
    git-sizer # Compute various size metrics for Git repo
    bfg-repo-cleaner # BFG Repo-Cleaner for removing large files
    git-filter-repo # Quickly rewrite git repository history

    # Note: viddy and upterm are in desktop-packages.nix
    # Note: svu is in development.nix
    # Note: just is in minimal.nix
  ];
}
