#!/usr/bin/env zsh
#
# Shared helpers for project-specific Zsh plugins.

if [[ -n "${DEV_HELPERS_LOADED:-}" ]]; then
  return
fi
export DEV_HELPERS_LOADED=1

dev::log() {
  print -- "→ $*"
}

dev::warn() {
  print -P "%F{yellow}⚠%f $*" >&2
}

dev::set_tmux_tab() {
  local name=$1
  [[ -z "$name" ]] && return
  if typeset -f __set_tmux_tab_name >/dev/null 2>&1; then
    __set_tmux_tab_name "$name"
  fi
}

dev::safe_branch_name() {
  local branch=$1
  branch=${branch//\//-}
  branch=${branch// /-}
  print -- "$branch"
}

dev::worktree_path() {
  local base=$1
  local branch=$2
  local safe
  safe=$(dev::safe_branch_name "$branch")
  print -- "${base%/}/$safe"
}

dev::run_git_worktree() {
  local dest=$1
  local branch=$2
  local base=${3:-main}

  git worktree add "$dest" -b "$branch" "$base"
}

dev::secret() {
  local var=$1
  local placeholder=$2
  local desc=$3
  local value=${(P)var):-}

  if [[ -z "$value" ]]; then
    [[ -n "$placeholder" ]] || placeholder="__SET_${var}__"
    [[ -n "$desc" ]] || desc="$var"
    dev::warn "$desc is not set; using placeholder. Add it to ~/.config/dev/secrets.zsh"
    value=$placeholder
  fi

  REPLY=$value
}

dev::ensure_dir() {
  mkdir -p "$1"
}
