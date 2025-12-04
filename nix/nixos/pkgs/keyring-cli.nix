{ lib
, buildGoModule
}:

buildGoModule {
  pname = "keyring-cli";
  version = "0.1.0";

  src = ../../.tools/keyring-cli;

  vendorHash = "sha256-9pfVy74LqaJLqUaZvlbLUJ7Dw/L18zB79iY5c+X5b/g=";

  meta = with lib; {
    description = "Simple CLI for cross-platform keyring access using 99designs/keyring";
    homepage = "https://github.com/user/keyring-cli";
    license = licenses.mit;
    platforms = platforms.unix ++ platforms.windows;
  };
}
