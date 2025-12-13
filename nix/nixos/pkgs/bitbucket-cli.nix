# bitbucket-cli - CLI for Bitbucket (gildas/bitbucket-cli)
{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "bitbucket-cli";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "gildas";
    repo = "bitbucket-cli";
    rev = "v${version}";
    hash = "sha256-ZoPvqhxvmZ9UOnD00BUP8e859n40qLwlrTn6mU+5Qhw=";
  };

  vendorHash = null; # Uses vendored dependencies

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  # Binary is named 'bb'
  postInstall = ''
    mv $out/bin/bitbucket-cli $out/bin/bb
  '';

  meta = with lib; {
    description = "Bitbucket CLI tool";
    homepage = "https://github.com/gildas/bitbucket-cli";
    license = licenses.mit;
    mainProgram = "bb";
  };
}
