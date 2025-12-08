# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
path_prepend_unique "$PNPM_HOME"
# pnpm end

export LOCAL_BIN="$HOME/.local/bin"
path_prepend_unique "$LOCAL_BIN"
path_prepend_unique "/opt/homebrew/opt/openjdk/bin"
path_append_unique "$(go env GOPATH)/bin"

if [[ -f "$HOME/.config/dev/secrets.zsh" ]]; then
  source "$HOME/.config/dev/secrets.zsh"
fi

export GOOGLE_CLOUD_SDK_ROOT="/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
if [ -d "{$GOOGLE_CLOUD_SDK_ROOT}" ]; then
  source "$GOOGLE_CLOUD_SDK_ROOT/completion.zsh.inc"
  source "$GOOGLE_CLOUD_SDK_ROOT/path.zsh.inc"
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export PHPENV_ROOT="$HOME/.local/share/phpenv"
if [ -d "${PHPENV_ROOT}" ]; then
  path_prepend_unique "${PHPENV_ROOT}/bin"
  eval "$(phpenv init -)"
fi

# Get java home from libexec
if command -v /usr/libexec/java_home &> /dev/null; then
  export JAVA_HOME="$(/usr/libexec/java_home -v 17)"
  path_prepend_unique "$JAVA_HOME/bin"
fi

export LDFLAGS="-L/opt/homebrew/opt/mysql-client/lib"
export CPPFLAGS="-I/opt/homebrew/opt/mysql-client/include"

export PKG_CONFIG_PATH="/opt/homebrew/opt/mysql-client/lib/pkgconfig"
path_prepend_unique "/opt/homebrew/bin"

# Keep the Nix profile tools available; ensure_nix_path_priority later moves them to the front
path_prepend_unique "$HOME/.nix-profile/bin"
