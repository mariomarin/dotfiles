{ lib, buildNpmPackage, fetchFromGitHub }:

buildNpmPackage {
  pname = "jj-stack";
  version = "0.3.0-unstable";

  src = fetchFromGitHub {
    owner = "keanemind";
    repo = "jj-stack";
    rev = "main";
    hash = "sha256-fk+FZv4lu+noM6ig4NFGAlRy4AWdEjkLIDZZ877bKLs=";
  };

  npmDepsHash = "sha256-RVOnxdzSpgyxfS+EZS1oIlX+chUl8GyLXKrmVlEmLPg=";

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
