{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "cf-vault";
  version = "0.0.18";

  src = fetchFromGitHub {
    owner = "jacobbednarz";
    repo = "cf-vault";
    rev = "v${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Will update after first build
  };

  vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Will update after first build

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
