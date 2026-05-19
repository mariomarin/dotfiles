{ lib, stdenv, fetchFromGitHub, go }:

stdenv.mkDerivation rec {
  pname = "clipper";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "wincent";
    repo = "clipper";
    rev = version;
    hash = "sha256-3ZDLkaP5nqb7TBApoVQBha2NNfyP1BxvC+WtVArBF78=";
  };

  nativeBuildInputs = [ go ];

  buildPhase = ''
    export HOME=$TMPDIR
    go build -ldflags="-X main.version=${version}" -o clipper clipper.go
  '';

  installPhase = ''
    install -Dm755 clipper $out/bin/clipper
  '';

  meta = with lib; {
    description = "Clipboard access over SSH via a daemon";
    homepage = "https://github.com/wincent/clipper";
    license = licenses.bsd2;
    mainProgram = "clipper";
  };
}
