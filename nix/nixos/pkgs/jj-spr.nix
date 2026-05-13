{ lib, rustPlatform, fetchFromGitHub, pkg-config, openssl, zlib, git, jujutsu }:

rustPlatform.buildRustPackage {
  pname = "jj-spr";
  version = "0.1.0-unstable";

  src = fetchFromGitHub {
    owner = "jennings";
    repo = "jj-spr";
    rev = "main";
    hash = "sha256-dpeLf8h31AoGDhVw8raqqPTFMCjAU1juAr63M5qMeb4=";
  };

  cargoHash = "sha256-ragGArEAsFts9BeRZDelec8Efm5QMzJyrM98uSUMNIU=";

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
