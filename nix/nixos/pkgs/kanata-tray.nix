# kanata-tray - System tray for kanata keyboard remapper
{ lib, stdenv, fetchurl }:

let
  version = "0.8.0";
  assets = {
    "x86_64-linux" = {
      name = "kanata-tray-linux";
      hash = "sha256-o0uePeLHx/IivpT2L/+chrRo2to4weao1unpkVRvp00=";
    };
    "x86_64-darwin" = {
      name = "kanata-tray-macos";
      hash = "sha256-ZF4q08LFRiYsWTxHIY4YrLjelr0ZG1OTgkwOD3JMY/k=";
    };
    "aarch64-darwin" = {
      name = "kanata-tray-macos";
      hash = "sha256-ZF4q08LFRiYsWTxHIY4YrLjelr0ZG1OTgkwOD3JMY/k=";
    };
  };
  asset = assets.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "kanata-tray";
  inherit version;

  src = fetchurl {
    url = "https://github.com/rszyma/kanata-tray/releases/download/v${version}/${asset.name}";
    hash = asset.hash;
  };

  dontUnpack = true;

  installPhase = ''
    install -D $src $out/bin/kanata-tray
  '';

  meta = with lib; {
    description = "System tray icon for kanata keyboard remapper";
    homepage = "https://github.com/rszyma/kanata-tray";
    license = licenses.mit;
    mainProgram = "kanata-tray";
    platforms = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
  };
}
