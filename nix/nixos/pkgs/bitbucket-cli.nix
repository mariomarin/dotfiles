# bitbucket-cli - CLI for Bitbucket (gildas/bitbucket-cli)
{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "bitbucket-cli";
  version = "0.18.7";

  src = fetchFromGitHub {
    owner = "gildas";
    repo = "bitbucket-cli";
    rev = "v${version}";
    hash = "sha256-HJCaZ5CQaKnnwZkmHGLuUotCTNQVi/pwaVYj2aGkRk8=";
  };

  vendorHash = "sha256-KDJAe2Bl/tkI5W/fwWhzAJJGBwHqiGFT+7HxHvarB6Y=";

  doCheck = false; # Tests require network/credentials

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  meta = with lib; {
    description = "Bitbucket CLI tool";
    homepage = "https://github.com/gildas/bitbucket-cli";
    license = licenses.mit;
    mainProgram = "bb";
  };
}
