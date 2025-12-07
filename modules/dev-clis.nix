{ config, lib, pkgs, ... }:

let
  npmGlobal = "${config.home.homeDirectory}/.local/npm-global";
  npmBin = "${npmGlobal}/bin";
  localBin = "${config.home.homeDirectory}/.local/bin";
  npmEnv = ''
    export NPM_CONFIG_PREFIX="${npmGlobal}"
    export PATH="${npmBin}:${pkgs.nodejs_24}/bin:$PATH"
  '';
in
{
  home.sessionVariables.NPM_CONFIG_PREFIX = npmGlobal;
  home.sessionPath = lib.mkAfter [ npmBin localBin ];

  home.activation.ensureCliDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.coreutils}/bin/mkdir -p ${npmBin}
    ${pkgs.coreutils}/bin/mkdir -p ${localBin}
  '';

  home.activation.installCodexCli = lib.hm.dag.entryAfter [ "ensureCliDirs" ] ''
    ${npmEnv}
    ${pkgs.nodejs_24}/bin/npm install -g @openai/codex@latest
  '';

  home.activation.installCopilotCli = lib.hm.dag.entryAfter [ "installCodexCli" ] ''
    ${npmEnv}
    ${pkgs.nodejs_24}/bin/npm install -g @github/copilot@latest
  '';

  home.activation.installClaudeCli = lib.hm.dag.entryAfter [ "ensureCliDirs" ] ''
    export PATH="${localBin}:${pkgs.nodejs_24}/bin:${pkgs.curl}/bin:${pkgs.coreutils}/bin:${pkgs.openssl}/bin:${pkgs.perl}/bin:${pkgs.gnugrep}/bin:${pkgs.gnused}/bin:$PATH"
    sha_expected="54715810c1e802c8aca39cc867ae9b2ec764574e20f2a653c97ec61bebc07d68"
    install_path="$TMPDIR/claude-install.sh"
    ${pkgs.curl}/bin/curl -fsSL -o "$install_path" https://claude.ai/install.sh
    actual_sha="$(${pkgs.openssl}/bin/openssl dgst -sha256 "$install_path" | ${pkgs.gnused}/bin/sed 's/^.*= //')"
    if [ "$actual_sha" != "$sha_expected" ]; then
      echo "Checksum verification failed" >&2
      exit 1
    fi
    ${pkgs.bash}/bin/bash "$install_path"
  '';
}
