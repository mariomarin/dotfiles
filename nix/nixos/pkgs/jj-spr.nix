{ lib, rustPlatform, fetchFromGitHub, pkg-config, openssl, zlib, git, jujutsu }:

rustPlatform.buildRustPackage {
  pname = "jj-spr";
  version = "0-unstable-2026-07-28";

  src = fetchFromGitHub {
    owner = "jennings";
    repo = "jj-spr";
    rev = "998ee83de8d7dee301a0109cc3feed421c86cae0";
    hash = "sha256-djt781zEGhvhsI9CnFxCkopICFHg/hLpo2RK2HO0mfY=";
  };

  cargoHash = "sha256-4fRM2fMlEFM9d/W4QyBrBebtsQpPuq4hELKQBU74FLE=";

  buildInputs = [ openssl zlib ];
  nativeBuildInputs = [ pkg-config git jujutsu ];

  doCheck = false;

  meta = with lib; {
    description = "Jujutsu subcommand for submitting stacked PRs to GitHub";
    homepage = "https://github.com/jennings/jj-spr";
    license = licenses.mit;
    mainProgram = "jj-spr";
  };
}
