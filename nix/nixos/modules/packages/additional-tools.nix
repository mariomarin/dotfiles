# Additional specialized tools module
# Domain-specific tools for Kubernetes, cloud, git utilities, and media
{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Data processing
    xan

    # Kubernetes
    kubectl
    stern
    krew

    # Cloud tools
    awscli2
    aws-sso-cli

    # Development
    jd-diff-patch

    # Search
    meilisearch

    # Media
    yewtube
    yt-dlp

    # Git utilities
    git-branchless
    git-sizer
    bfg-repo-cleaner
    git-filter-repo
  ];
}
