{ lib, rustPlatform, fetchFromGitHub, pkg-config, openssl }:

rustPlatform.buildRustPackage {
  pname = "jj-hooks";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "mattwilkinsonn";
    repo = "jj-hooks";
    rev = "v0.6.0";
    hash = "sha256-bd4Y82Jez5FBPr7rcHG6kdC1t50s3qUF/gMD9fmxDKs=";
  };

  cargoHash = "sha256-Dv86wJ6ZR+rpb5CqL1CFm0kDFTAZYwNAGoHmIZjGCK0=";

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
