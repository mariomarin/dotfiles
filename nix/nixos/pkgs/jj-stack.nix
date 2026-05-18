{ lib, buildNpmPackage, fetchFromGitHub, nodejs }:

buildNpmPackage {
  pname = "jj-stack";
  version = "0.3.0-unstable";

  src = fetchFromGitHub {
    owner = "keanemind";
    repo = "jj-stack";
    rev = "main";
    hash = lib.fakeHash;
  };

  npmDepsHash = lib.fakeHash;

  buildPhase = ''
    npm run build
  '';

  installPhase = ''
    mkdir -p $out/bin $out/lib
    cp -r dist $out/lib/
    cp -r node_modules $out/lib/
    cat > $out/bin/jj-stack <<'WRAPPER'
    #!/usr/bin/env node
    WRAPPER
    # Append the actual require
    echo "require('$out/lib/dist/cli/index.js');" >> $out/bin/jj-stack
    chmod +x $out/bin/jj-stack
  '';

  meta = with lib; {
    description = "CLI for stacked PRs on GitHub with Jujutsu";
    homepage = "https://github.com/keanemind/jj-stack";
    license = licenses.mit;
    mainProgram = "jst";
  };
}
