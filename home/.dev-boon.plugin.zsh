#!/usr/bin/env zsh

########################################
# Git Worktree Helpers
########################################

alias gtwbc='__git_worktree_boon_core'   # boon-core specific
alias gtwtms='__git_worktree_tms_api'    # tms-api-server specific
alias gtwbp='__git_worktree_boon_parser' # boon-parser specific

__boon_tmux_tab() {
  if typeset -f __set_tmux_tab_name >/dev/null 2>&1; then
    __set_tmux_tab_name "$1"
  fi
}

__git_worktree() {
  local branch=$1
  local base=${2:-main}
  local dir="../$branch"

  if [[ -z "$branch" ]]; then
    echo "Usage: gtw <branch-name> [base-branch]"
    return 1
  fi

  git worktree add "$dir" -b "$branch" "$base" || return 1
  cd "$dir" || return 1
  __boon_tmux_tab "$branch"
}

__git_worktree_boon_core() {
  local branch=$1
  shift
  local base_branch="main"
  local open_code=false

  if [[ -z "$branch" ]]; then
    echo "Usage: gtwbc <branch-name> [base-branch] [--code]"
    return 1
  fi

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

  local safe_dir_name=${branch//\//-}
  local dir="$BOONAI_DEV_DIR/worktrees/$safe_dir_name"

  git worktree add "$dir" -b "$branch" "$base_branch" || return 1
  cd "$dir/packages/boon-core" || return 1
  __boon_tmux_tab "$branch"

  echo "→ Restoring local dev setup…"
  ln -sf ~/nix-config/devshells/boon-core/.envrc .envrc
  ln -sf ~/nix-config/devshells/boon-core/shell.nix shell.nix
  ln -sf ~/nix-config/devshells/boon-core/process-compose.yaml process-compose.yaml

  echo "→ Installing dependencies…"
  npm install || return 1
  bundle install || return 1

  echo "→ Running migrations…"
  DISABLE_SPRING=1 make migrate

  if [[ "$open_code" == true ]]; then
    if command -v code >/dev/null 2>&1; then
      code .
    else
      echo "⚠️  'code' command not found; skipping VS Code launch."
    fi
  fi
}

__git_worktree_tms_api() {
  local branch=$1
  local base=${2:-main}
  local dir="$BOONAI_DEV_DIR/$branch"

  if [[ -z "$branch" ]]; then
    echo "Usage: gtwtms <branch-name> [base-branch]"
    return 1
  fi

  git worktree add "$dir" -b "$branch" "$base" || return 1
  cd "$dir/packages/tms-api-server" || return 1
  __boon_tmux_tab "$branch"

  echo "→ Running code generation tasks…"
  make _download_boon_parser_api_specification
  make _download_samsara_api_specification
  make _generate_pcs_client
  make _generate_samsara_client
  make _generate_boon_parser_client

  echo "✅ Setup done! You can now start the server with:"
  echo "   cd $dir/packages/tms-api-server && make run"
}

__git_worktree_boon_parser() {
  local branch=$1
  local base=${2:-main}
  local dir="$BOONAI_DEV_DIR/$branch"

  if [[ -z "$branch" ]]; then
    echo "Usage: gtwbp <branch-name> [base-branch]"
    return 1
  fi

  git worktree add "$dir" -b "$branch" "$base" || return 1
  cd "$dir/packages/boon-parser" || return 1
  __boon_tmux_tab "$branch"

  echo "→ Copying updated cursor rule from local setup"
  cp -r "$BOONAI_DEV_DIR/boon/packages/boon-core/.cursor" ".cursor"

  echo "✅ Setup done! You can now start the server with:"
  echo "   cd $dir/packages/boon-parser && make run"
}


########################################
# Boon Core Shortcuts
########################################

bc_bg() {
  local name=$1
  shift
  local logfile="log/${name}.log"
  local pidfile="log/${name}.pid"

  mkdir -p "log"
  echo "→ Starting $name (logs: $logfile, pid: $pidfile)"
  ("$@" >"$logfile" 2>&1 & echo $! >"$pidfile")
}

bc_stop() {
  local name=$1
  local pidfile="log/${name}.pid"

  if [[ -f "$pidfile" ]]; then
    local pid=$(cat "$pidfile")
    if kill "$pid" 2>/dev/null; then
      rm "$pidfile"
      echo "→ Stopped $name (pid $pid)"
    else
      echo "⚠️  Failed to kill $name (pid $pid). Maybe already dead?"
    fi
  else
    echo "⚠️  No pidfile for $name"
  fi
}

bc_stop_all() {
  for pidfile in log/*.pid; do
    [[ -f "$pidfile" ]] || continue
    bc_stop "$(basename "$pidfile" .pid)"
  done
}

# Aliases to start services
alias bcdev-web='bc_bg web bin/rails server -p 3000'
alias bcdev-css='bc_bg css bin/rails tailwindcss:watch'
alias bcdev-sidekiq='bc_bg sidekiq bundle exec sidekiq'
alias bcdev-sq-backhauls='bc_bg sidekiq-backhauls bundle exec sidekiq -q backhauls'
alias bcdev-sq-bheval='bc_bg sidekiq-backhaul-evaluation bundle exec sidekiq -q backhaul_evaluation'
alias bcdev-sq-autodispatch='bc_bg sidekiq-automated-dispatch bundle exec sidekiq -q automated_dispatch'
alias bcdev-sq-data-imports='bc_bg sidekiq-data-imports bundle exec sidekiq -q data_imports'
alias bcdev-sq-workflow-eval='bc_bg sidekiq-workflow-evaluation bundle exec sidekiq -q workflow_evaluation'
alias bcdev-mailpit='bc_bg mailpit ./mailpit.sh'
alias bcdev-rubocop='bc_bg rubocop-server bin/rubocop --start-server --no-detach'

# Aliases to stop
alias bcdev-stop='bc_stop'
alias bcdev-stop-all='bc_stop_all'
alias bcdev-restart='bc_stop_all && echo "→ Restarting boon-core…" && bcdev-web && bcdev-sidekiq'


########################################
# TMS API Server Shortcuts
########################################

tms_bg() {
  local name=$1
  shift
  local logfile="log/${name}.log"
  local pidfile="log/${name}.pid"

  mkdir -p "log"
  echo "→ Starting $name (logs: $logfile, pid: $pidfile)"
  ("$@" >"$logfile" 2>&1 & echo $! >"$pidfile")
}

tms_stop() {
  local pidfile="log/server.pid"
  if [[ -f "$pidfile" ]]; then
    local pid=$(cat "$pidfile")
    if kill "$pid" 2>/dev/null; then
      rm "$pidfile"
      echo "→ Stopped tms-api-server (pid $pid)"
    else
      echo "⚠️  Failed to kill tms-api-server (pid $pid). Maybe already dead?"
    fi
  else
    echo "⚠️  No pidfile found for tms-api-server"
  fi
}

alias tms-run='tms_bg server make run'
alias tms-stop='tms_stop'
alias tms-restart='tms-stop && echo "→ Restarting tms-api-server…" && tms-run'
