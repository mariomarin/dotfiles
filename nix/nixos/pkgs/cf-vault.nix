{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "cf-vault";
  version = "0.0.18-unstable-2025-11-24";

  src = fetchFromGitHub {
    owner = "jacobbednarz";
    repo = "cf-vault";
    rev = "1f1b2937c75722f741b2a014f461776aed006237";
    hash = "sha256-14/A9Netf7SxoYNBTDrZ5VUuGRzW13UeyerA8IM8cz0=";
  };

  vendorHash = "sha256-pq/qKmylRU3cnsDEC2c0E5uPe6zQTmZUEEa/TNqSYbQ=";

  # Remove tools directory which has broken gopls dependencies
  postPatch = ''
    rm -rf tools
    sed -i '/tools/d' go.mod
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  meta = with lib; {
    description = "Manage your Cloudflare credentials, securely";
    homepage = "https://github.com/jacobbednarz/cf-vault";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "cf-vault";
    platforms = platforms.unix ++ platforms.windows;
  };
}
