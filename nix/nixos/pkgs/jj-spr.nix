{ lib, rustPlatform, fetchFromGitHub, pkg-config, openssl, zlib, git, jujutsu }:

rustPlatform.buildRustPackage {
  pname = "jj-spr";
  version = "0.1.0-unstable";

  src = fetchFromGitHub {
    owner = "jennings";
    repo = "jj-spr";
    rev = "main";
    hash = "sha256-HO8kbaklJAvNZHHto+Ph0rpb8vPOkgGw7FGH7vtIB9w=";
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
