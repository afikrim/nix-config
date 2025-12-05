# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
# pnpm end

export LOCAL_BIN="$HOME/.local/bin"
export PATH="$LOCAL_BIN:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="$PATH:$(go env GOPATH)/bin"

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
  export PATH="${PHPENV_ROOT}/bin:${PATH}"
  eval "$(phpenv init -)"
fi

# Get java home from libexec
if command -v /usr/libexec/java_home &> /dev/null; then
  export JAVA_HOME="$(/usr/libexec/java_home -v 17)"
  export PATH="$JAVA_HOME/bin:$PATH"
fi

export LDFLAGS="-L/opt/homebrew/opt/mysql-client/lib"
export CPPFLAGS="-I/opt/homebrew/opt/mysql-client/include"

export PKG_CONFIG_PATH="/opt/homebrew/opt/mysql-client/lib/pkgconfig"
export PATH="/opt/homebrew/bin:$PATH"
