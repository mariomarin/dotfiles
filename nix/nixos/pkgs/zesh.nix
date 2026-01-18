# zesh - Zellij session manager with zoxide integration
{ lib, stdenv, fetchurl }:

let
  version = "0.3.0";
  binary = if stdenv.isDarwin then "zesh-macos" else "zesh";
  hash =
    if stdenv.isDarwin
    then "sha256-uZoaHJ9rkPdbdqmUFzxJHXKZAUBtsXuFfA8dwJydoUc="
    else "sha256-LUESpUk4FxwK3EcpZQXDwwbQFOELlk3R9XdtdnpeTh8=";
in
stdenv.mkDerivation {
  pname = "zesh";
  inherit version;

  src = fetchurl {
    url = "https://github.com/roberte777/zesh/releases/download/zesh-v${version}/${binary}";
    inherit hash;
  };

  dontUnpack = true;

  installPhase = ''
    install -D $src $out/bin/zesh
  '';

  meta = with lib; {
    description = "Zellij session manager with zoxide integration";
    homepage = "https://github.com/roberte777/zesh";
    license = licenses.mit;
    mainProgram = "zesh";
    platforms = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
  };
}
