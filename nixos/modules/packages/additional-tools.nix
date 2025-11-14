# Additional specialized tools module
# Provides domain-specific tools (Kubernetes, cloud, git utilities, media)
{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Data processing and utilities
    xan # CSV data manipulation toolkit (maintained fork of xsv)

    # Kubernetes tools
    stern # Multi pod and container log tailing
    krew # Kubernetes plugin manager

    # Network and cloud tools
    awscli # AWS CLI v1
    aws-sso-cli # AWS SSO authentication helper

    # Development and diff tools
    jd-diff-patch # JSON diff and patch

    # Search and indexing
    meilisearch # Fast, open-source search engine

    # Media and download tools
    yewtube # Terminal YouTube viewer
    yt-dlp # YouTube downloader

    # Git utilities
    git-branchless # Git workflow for trunk-based development
    git-sizer # Compute various size metrics for Git repo
    bfg-repo-cleaner # BFG Repo-Cleaner for removing large files
    git-filter-repo # Quickly rewrite git repository history
  ];
}
