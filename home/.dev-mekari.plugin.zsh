#!/usr/bin/env zsh

########################################
# Git Worktree Helpers for Accounting Service
########################################

alias gtwacc='__git_worktree_accounting_service'

__mekari_tmux_tab() {
  if typeset -f __set_tmux_tab_name >/dev/null 2>&1; then
    __set_tmux_tab_name "$1"
  fi
}

__git_worktree_accounting_service() {
  local worktree_branch=$1
  shift
  local base_branch="v_next"
  local open_code=false

  if [[ -z "$worktree_branch" ]]; then
    echo "Usage: gtwacc <new-branch> [base-branch] [--code]"
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

  local safe_dir_name=${worktree_branch//\//-}
  local worktree_dir="$MEKARI_DEV_DIR/worktrees/$safe_dir_name"
  local vscode_dir="$worktree_dir/.vscode"
  local env_file="$vscode_dir/.env"
  local mcp_file="$vscode_dir/mcp.json"

  echo "→ Creating accounting_service worktree for $worktree_branch from $base_branch at $worktree_dir…"
  git worktree add -b "$worktree_branch" "$worktree_dir" "$base_branch" || return 1

  cd "$worktree_dir" || return 1
  __mekari_tmux_tab "$worktree_branch"

  echo "→ Preparing VS Code environment variables…"
  mkdir -p "$vscode_dir"
  cat <<'EOF' > "$env_file"
# GitHub Configuration
GITHUB_PERSONAL_ACCESS_TOKEN=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

# Search APIs
BRAVE_API_KEY=BSAGYW5M8rVnsrJD7tdoP-nRfQQOYXH
TAVILY_API_KEY=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

# Atlassian Configuration
CONFLUENCE_URL=https://jurnal.atlassian.net
CONFLUENCE_USERNAME=aziz.fikri@mekari.com
CONFLUENCE_API_TOKEN=ATATT3xFfGF0bzc9Naf74lLfJz-lGtMK76FSLh0TmVoIZ2o-XXdfKR459Cv3PufZ4zI_qZxwlnRLLMk7ZuN2boxROw-cg16nW7zzM2yCERUKoqAMx8pi-rU87s8NlOsXqYQvw9Pyhu0ndYPTFEi3dbnpb8AJX3X9OrdPXtJhSFaxP3PqPoOeQuo=7EEF41FF
JIRA_URL=https://jurnal.atlassian.net
JIRA_USERNAME=aziz.fikri@mekari.com
JIRA_API_TOKEN=ATATT3xFfGF0bzc9Naf74lLfJz-lGtMK76FSLh0TmVoIZ2o-XXdfKR459Cv3PufZ4zI_qZxwlnRLLMk7ZuN2boxROw-cg16nW7zzM2yCERUKoqAMx8pi-rU87s8NlOsXqYQvw9Pyhu0ndYPTFEi3dbnpb8AJX3X9OrdPXtJhSFaxP3PqPoOeQuo=7EEF41FF

# Bitbucket Configuration
ATLASSIAN_BITBUCKET_USERNAME=afikrim_mkr
ATLASSIAN_BITBUCKET_APP_PASSWORD=ATBByDqgmmjBYMFJZWSm8EJDUehGE46E7B1B
EOF

  cat <<'EOF' > "$mcp_file"
{
  "servers": {
    // @deprecated
    // new copilot support thinking out of the box
    // "sequential-thinking": {
    //   "command": "npx",
    //   "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    // },

    // Editor Agent
    // Best for complex implementation and huge read / write
    // "serena-server": {
    //   "type": "stdio",
    //   "command": "uvx",
    //   "args": [
    //     "--from",
    //     "git+https://github.com/oraios/serena",
    //     "serena",
    //     "start-mcp-server",
    //     "--context",
    //     "ide-assistant",
    //     "--project",
    //     "$(pwd)"
    //   ],
    //   "env": {}
    // },

    // Search Engine
    // Recommend: Omnisearch + Context7 with Brave & Tavily API Key (Free)
    // "g-search": {
    //   "command": "npx",
    //   "args": ["-y", "g-search-mcp"]
    // },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"],
      "envFile": "${workspaceFolder}/.vscode/.env"
    },
    "omnisearch": {
      "command": "npx",
      "args": ["-y", "mcp-omnisearch@0.0.17"],
      "envFile": "${workspaceFolder}/.vscode/.env"
    },

    // Source Code Management
    // "github": {
    //   "command": "npx",
    //   "args": ["-y", "@modelcontextprotocol/server-github"],
    //   "envFile": "${workspaceFolder}/.vscode/.env"
    // }

    // "bitbucket": {
    //   "command": "npx",
    //   "args": ["-y", "@aashari/mcp-server-atlassian-bitbucket"],
    //   "envFile": "${workspaceFolder}/.vscode/.env"
    // }


    // Atlassian
    // Used for fetching jira task or confluence docs
    // "atlassian": {
    //   "command": "docker",
    //   "args": [
    //     "run",
    //     "-i",
    //     "--rm",
    //     "-e",
    //     "CONFLUENCE_URL",
    //     "-e",
    //     "CONFLUENCE_USERNAME",
    //     "-e",
    //     "CONFLUENCE_API_TOKEN",
    //     "-e",
    //     "JIRA_URL",
    //     "-e",
    //     "JIRA_USERNAME",
    //     "-e",
    //     "JIRA_API_TOKEN",
    //     "ghcr.io/sooperset/mcp-atlassian:latest"
    //   ],
    //   "envFile": "${workspaceFolder}/.vscode/.env"
    // }
  }
}
EOF

  echo "→ Restoring local dev setup…"
  ln -sf ~/nix-config/devshells/accounting_service/.envrc .envrc
  ln -sf ~/nix-config/devshells/accounting_service/shell.nix shell.nix
  ln -sf ~/nix-config/devshells/accounting_service/process-compose.yaml process-compose.yaml
  ln -sf ~/nix-config/devshells/accounting_service/services dev/services

  if [[ "$open_code" == true ]]; then
    if command -v code >/dev/null 2>&1; then
      echo "→ Opening VS Code…"
      code .
    else
      echo "⚠️  'code' command not found; skipping VS Code launch."
    fi
  fi

  echo "✅ Worktree ready at: $worktree_dir"
}


########################################
# Git Worktree Helpers for Quickbook
########################################

alias gtwqb='__git_worktree_quickbook'

__git_worktree_quickbook() {
  local branch=$1       # new branch name
  local source=${2:-v_next} # source branch (default: v_next)
  local dir="$MEKARI_DEV_DIR/$branch"

  if [[ -z "$branch" ]]; then
    echo "Usage: gtwqb <new-branch> [source-branch]"
    return 1
  fi

  echo "→ Creating worktree at $dir (branch: $branch, from: $source)…"
  git worktree add "$dir" -b "$branch" "$source" || return 1

  cd "$dir" || return 1
  __mekari_tmux_tab "$branch"

  echo "→ Restoring local dev setup…"
  ln -sf ~/nix-config/devshells/quickbook/.envrc .envrc
  ln -sf ~/nix-config/devshells/quickbook/shell.nix shell.nix
  ln -sf ~/nix-config/devshells/quickbook/process-compose.yaml process-compose.yaml

  echo "→ Installing dependencies…"
  yarn install || return 1
  bundle install || return 1

  echo "✅ Worktree setup complete for quickbook at: $dir"
  echo "   You are now inside quickbook directory."
  echo ""
  echo "💡 Quick start:"
  echo "   rails server"
}
