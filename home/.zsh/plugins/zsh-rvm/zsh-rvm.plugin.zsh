ZSH_RVM_DIR=${0:a:h}

[[ -z "$RVM_DIR" ]] && export RVM_DIR="$HOME/.rvm"

_zsh_rvm_rename_function() {
  test -n "$(declare -f $1)" || return
  eval "${_/$1/$2}"
  unset -f $1
}

_zsh_rvm_has() {
  type "$1" > /dev/null 2>&1
}

_zsh_rvm_install() {
  echo "Installing RVM..."
  \curl -sSL https://get.rvm.io | bash -s stable --auto-dotfiles
}

_zsh_rvm_load() {
  source "$RVM_DIR/scripts/rvm"
  _zsh_rvm_rename_function rvm _zsh_rvm_rvm
  rvm() {
    case $1 in
      'upgrade')
        _zsh_rvm_upgrade
        ;;
      'revert')
        _zsh_rvm_revert
        ;;
      *)
        _zsh_rvm_rvm "$@"
        ;;
    esac
  }
}

_zsh_rvm_completion() {
  [[ -r $RVM_DIR/scripts/completion ]] && source $RVM_DIR/scripts/completion
}

_zsh_rvm_lazy_load() {
  local global_binaries=(rvm)
  local cmd
  for cmd in $global_binaries; do
    eval "$cmd(){
      unset -f $cmds > /dev/null 2>&1
      _zsh_rvm_load
      $cmd \"\$@\"
    }"
  done
}

_zsh_rvm_auto_use() {
  if [[ -f .ruby-version ]]; then
    local ruby_version="$(cat .ruby-version)"
    rvm use "$ruby_version" --install --quiet
  fi
}

rvm_update() {
  echo 'Deprecated, please use `rvm upgrade`'
}

_zsh_rvm_upgrade() {
  local installed_version=$(rvm --version | grep -o "rvm [^ ]*" | cut -d' ' -f2)
  echo "Installed version is $installed_version"
  echo "Checking latest version of RVM..."
  local latest_version=$(rvm get head)
  if [[ "$installed_version" = "$latest_version" ]]; then
    echo "You're already up to date"
  else
    echo "Updating to $latest_version..."
    echo "$installed_version" > "$ZSH_RVM_DIR/previous_version"
    rvm get stable
    _zsh_rvm_load
  fi
}

_zsh_rvm_previous_version() {
  cat "$ZSH_RVM_DIR/previous_version" 2>/dev/null
}

_zsh_rvm_revert() {
  local previous_version="$(_zsh_rvm_previous_version)"
  if [[ -n "$previous_version" ]]; then
    local installed_version=$(rvm --version | grep -o "rvm [^ ]*" | cut -d' ' -f2)
    if [[ "$installed_version" = "$previous_version" ]]; then
      echo "Already reverted to $installed_version"
      return
    fi
    echo "Installed version is $installed_version"
    echo "Reverting to $previous_version..."
    rvm get "$previous_version"
    _zsh_rvm_load
  else
    echo "No previous version found"
  fi
}

autoload -U add-zsh-hook

if [[ "$ZSH_RVM_NO_LOAD" != true ]]; then

  [[ ! -f "$RVM_DIR/scripts/rvm" ]] && _zsh_rvm_install

  if [[ -f "$RVM_DIR/scripts/rvm" ]]; then

    [[ "$RVM_LAZY_LOAD" == true ]] && _zsh_rvm_lazy_load || _zsh_rvm_load

    [[ "$RVM_COMPLETION" == true ]] && _zsh_rvm_completion

    [[ "$RVM_AUTO_USE" == true ]] && add-zsh-hook chpwd _zsh_rvm_auto_use && _zsh_rvm_auto_use
  fi

fi

true

