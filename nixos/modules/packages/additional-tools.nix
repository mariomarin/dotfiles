{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Data processing and utilities
    xsv # CSV data manipulation toolkit

    # Kubernetes tools
    stern # Multi pod and container log tailing
    just # Command runner for project-specific tasks
    krew # Kubernetes plugin manager

    # Network and cloud tools
    speedtest-cli # Internet speed testing
    awscli # AWS CLI v1
    aws-sso-cli # AWS SSO authentication helper

    # Development and diff tools
    jd-diff-patch # JSON diff and patch
    ruff-lsp # Fast Python linter LSP

    # Media and download tools
    yewtube # Terminal YouTube viewer
    yt-dlp # YouTube downloader

    # Git utilities
    git-branchless # Git workflow for trunk-based development
    git-sizer # Compute various size metrics for Git repo
    bfg # BFG Repo-Cleaner for removing large files
    git-filter-repo # Quickly rewrite git repository history

    # System monitoring
    viddy # Modern watch command

    # Version management
    svu # Semantic Version Utility

    # Remote access
    upterm # Secure terminal sharing
  ];
}
