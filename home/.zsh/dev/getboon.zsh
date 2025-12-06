#!/usr/bin/env zsh

source "$HOME/.zsh/dev/helpers.zsh"

: "${GETBOON_DEV_DIR:=${GETBOON_DEV_DIR:-$HOME/Development/getboon}}"
: "${GETBOON_WORKTREES_DIR:=$GETBOON_DEV_DIR/worktrees}"

alias gtwbc='dev_getboon::core_worktree'
alias gtwtms='dev_getboon::tms_worktree'
alias gtwbp='dev_getboon::parser_worktree'

dev_getboon::core_worktree() {
  local branch=$1
  shift

  if [[ -z "$branch" ]]; then
    echo "Usage: gtwbc <branch-name> [base-branch] [--code]"
    return 1
  fi

  local base_branch="main"
  local open_code=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --code)
        open_code=true
        ;;
      *)
        base_branch="$1"
        ;;
    esac
    shift
  done

  local dir
  dir=$(dev::worktree_path "$GETBOON_WORKTREES_DIR" "$branch")

  dev::log "Creating boon-core worktree '$branch' from '$base_branch' at '$dir'"
  dev::run_git_worktree "$dir" "$branch" "$base_branch" || return 1

  cd "$dir/packages/boon-core" || return 1
  dev::set_tmux_tab "$branch"

  dev::log "Restoring config/database.yml from aziz/local-setup"
  git show aziz/local-setup:packages/boon-core/config/database.yml > config/database.yml

  if [[ -d "$GETBOON_DEV_DIR/boon/packages/boon-core/.serena" ]]; then
    dev::log "Copying .serena bootstrap config"
    rm -rf .serena
    cp -R "$GETBOON_DEV_DIR/boon/packages/boon-core/.serena" .serena
  fi

  dev::log "Installing JS/Ruby dependencies"
  command -v npm >/dev/null 2>&1 && npm install
  command -v bundle >/dev/null 2>&1 && bundle install

  dev::log "Running database migrations"
  DISABLE_SPRING=1 make migrate

  if $open_code && command -v code >/dev/null 2>&1; then
    code .
  elif $open_code; then
    dev::warn "'code' command not found; skipping VS Code launch."
  fi
}

dev_getboon::tms_worktree() {
  local branch=$1
  local base=${2:-main}

  if [[ -z "$branch" ]]; then
    echo "Usage: gtwtms <branch-name> [base-branch]"
    return 1
  fi

  local dir="$GETBOON_DEV_DIR/$branch"
  dev::log "Creating tms-api-server worktree '$branch' from '$base' at '$dir'"
  dev::run_git_worktree "$dir" "$branch" "$base" || return 1

  cd "$dir/packages/tms-api-server" || return 1
  dev::set_tmux_tab "$branch"

  dev::log "Running code generation tasks"
  make _download_boon_parser_api_specification
  make _download_samsara_api_specification
  make _generate_pcs_client
  make _generate_samsara_client
  make _generate_boon_parser_client

  dev::log "tms-api-server ready at $dir/packages/tms-api-server"
}

dev_getboon::parser_worktree() {
  local branch=$1
  local base=${2:-main}

  if [[ -z "$branch" ]]; then
    echo "Usage: gtwbp <branch-name> [base-branch]"
    return 1
  fi

  local dir="$GETBOON_DEV_DIR/$branch"
  dev::log "Creating boon-parser worktree '$branch' from '$base' at '$dir'"
  dev::run_git_worktree "$dir" "$branch" "$base" || return 1

  cd "$dir/packages/boon-parser" || return 1
  dev::set_tmux_tab "$branch"

  if [[ -d "$GETBOON_DEV_DIR/boon/packages/boon-core/.cursor" ]]; then
    dev::log "Copying Cursor rules from boon-core"
    rm -rf .cursor
    cp -R "$BOONAI_DEV_DIR/boon/packages/boon-core/.cursor" .cursor
  fi

  dev::log "boon-parser ready at $dir/packages/boon-parser"
}

dev_getboon::run_bg() {
  local name=$1
  shift

  mkdir -p log
  local logfile="log/${name}.log"
  local pidfile="log/${name}.pid"
  dev::log "Starting $name (log: $logfile)"
  ("$@" >"$logfile" 2>&1 & echo $! >"$pidfile")
}

dev_getboon::stop_bg() {
  local name=$1
  local pidfile="log/${name}.pid"

  if [[ -f "$pidfile" ]]; then
    local pid
    pid=$(cat "$pidfile")
    if kill "$pid" 2>/dev/null; then
      rm "$pidfile"
      dev::log "Stopped $name (pid $pid)"
    else
      dev::warn "Failed to stop $name (pid $pid)"
    fi
  fi
}

dev_getboon::stop_all_bg() {
  for pidfile in log/*.pid; do
    [[ -f "$pidfile" ]] || continue
    dev_boon::stop_bg "$(basename "$pidfile" .pid)"
  done
}

alias bcdev-web='dev_getboon::run_bg web bin/rails server -p 3000'
alias bcdev-css='dev_getboon::run_bg css bin/rails tailwindcss:watch'
alias bcdev-sidekiq='dev_getboon::run_bg sidekiq bundle exec sidekiq'
alias bcdev-sq-backhauls='dev_getboon::run_bg sidekiq-backhauls bundle exec sidekiq -q backhauls'
alias bcdev-sq-bheval='dev_getboon::run_bg sidekiq-backhaul-eval bundle exec sidekiq -q backhaul_evaluation'
alias bcdev-sq-autodispatch='dev_getboon::run_bg sidekiq-automated-dispatch bundle exec sidekiq -q automated_dispatch'
alias bcdev-sq-data-imports='dev_getboon::run_bg sidekiq-data-imports bundle exec sidekiq -q data_imports'
alias bcdev-sq-workflow-eval='dev_getboon::run_bg sidekiq-workflow-eval bundle exec sidekiq -q workflow_evaluation'
alias bcdev-mailpit='dev_getboon::run_bg mailpit ./mailpit.sh'
alias bcdev-rubocop='dev_getboon::run_bg rubocop-server bin/rubocop --start-server --no-detach'

alias bcdev-stop='dev_getboon::stop_bg'
alias bcdev-stop-all='dev_getboon::stop_all_bg'
alias bcdev-restart='dev_getboon::stop_all_bg && dev::log "Restarting boon-core…" && bcdev-web && bcdev-sidekiq'

dev_getboon::tms_stop() {
  local pidfile="log/server.pid"
  if [[ -f "$pidfile" ]]; then
    local pid
    pid=$(cat "$pidfile")
    if kill "$pid" 2>/dev/null; then
      rm "$pidfile"
      dev::log "Stopped tms-api-server (pid $pid)"
    else
      dev::warn "Failed to stop pid $pid"
    fi
  else
    dev::warn "No log/server.pid found"
  fi
}

alias tms-run='dev_getboon::run_bg server make run'
alias tms-stop='dev_getboon::tms_stop'
alias tms-restart='dev_getboon::tms_stop && dev::log "Restarting tms-api-server…" && tms-run'
