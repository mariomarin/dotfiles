{ lib, rustPlatform, fetchFromGitHub, pkg-config, openssl }:

rustPlatform.buildRustPackage {
  pname = "jj-hooks";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "mattwilkinsonn";
    repo = "jj-hooks";
    rev = "v0.1.4";
    hash = "sha256-6Vs/pLgxvgqFmU5RSJxVDImsyjk/ZNMiv7/mtOYJC/M=";
  };

  cargoHash = "sha256-7zgdvG1GinZtRYjqBxLaf6ULPE/4BKn6LlNumXWb1lY=";

  buildInputs = [ openssl ];
  nativeBuildInputs = [ pkg-config ];

  doCheck = false;

  meta = with lib; {
    description = "Run pre-commit/prek/lefthook/hk hooks against jj bookmark pushes";
    homepage = "https://github.com/mattwilkinsonn/jj-hooks";
    license = licenses.asl20;
    mainProgram = "jj-hp";
  };
}
