#!/usr/bin/env bash
# ~/.config/scripts/theme-switcher.sh
# Automatic theme switcher for zsh/powerlevel10k, tmux, and kitty

set -euo pipefail

# Configuration paths
ZSH_CONFIG="$HOME/.zshrc"
TMUX_CONFIG="$HOME/.tmux.conf"
KITTY_THEMES_DIR="$HOME/.config/kitty/themes"
KITTY_THEME_LINK="$HOME/.config/kitty/current-theme.conf"
P10K_LIGHT_CONFIG="$HOME/.p10k-light.zsh"
P10K_DARK_CONFIG="$HOME/.p10k.zsh"

LIGHT_THEME_NAME="one_light"
DARK_THEME_NAME="catppuccin_mocha"

# Theme detection function
detect_system_theme() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    local theme
    theme=$(osascript -e 'tell app "System Events" to tell appearance preferences to get dark mode')
    if [[ "$theme" == "true" ]]; then
      echo "dark"
    else
      echo "light"
    fi
  elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    if command -v gsettings >/dev/null 2>&1; then
      local gtk_theme
      gtk_theme=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null || echo "")
      if [[ "$gtk_theme" =~ -[Dd]ark ]]; then
        echo "dark"
      else
        echo "light"
      fi
    elif command -v kreadconfig5 >/dev/null 2>&1; then
      local color_scheme
      color_scheme=$(kreadconfig5 --file kdeglobals --group General --key ColorScheme 2>/dev/null || echo "")
      if [[ "$color_scheme" =~ [Dd]ark ]]; then
        echo "dark"
      else
        echo "light"
      fi
    else
      if [[ "${DARK_MODE:-}" == "1" ]]; then
        echo "dark"
      else
        echo "light"
      fi
    fi
  else
    echo "light"
  fi
}

# Update Kitty theme by moving the writable link
update_kitty_theme() {
  local theme=$1
  local theme_name target

  if [[ "$theme" == "dark" ]]; then
    theme_name=$DARK_THEME_NAME
  else
    theme_name=$LIGHT_THEME_NAME
  fi

  target="$KITTY_THEMES_DIR/${theme_name}.conf"

  if [[ ! -f "$target" ]]; then
    echo "Kitty theme $target not found"
    return 1
  fi

  mkdir -p "$(dirname "$KITTY_THEME_LINK")"
  ln -sf "$target" "$KITTY_THEME_LINK"
  echo "Updated Kitty theme to $theme ($theme_name)"
}

# Update tmux theme live without editing the config file
update_tmux_theme() {
  local theme=$1
  local tmux_theme

  if [[ ! -f "$TMUX_CONFIG" ]]; then
    echo "Tmux config not found at $TMUX_CONFIG"
    return 1
  fi

  if [[ "$theme" == "dark" ]]; then
    tmux_theme="night"
  else
    tmux_theme="day"
  fi

  if pgrep -x tmux >/dev/null; then
    tmux set -g @tokyo-night-tmux_theme "$tmux_theme" 2>/dev/null || true
    tmux display-message "Switched tmux theme to $tmux_theme" 2>/dev/null || true
  fi

  echo "Updated tmux theme to $theme ($tmux_theme)"
}

# Update environment variable for shell sessions
update_shell_theme() {
  local theme=$1
  local theme_file="$HOME/.current_theme"

  echo "$theme" >"$theme_file"
  export CURRENT_THEME="$theme"

  echo "Updated shell theme preference to $theme"
}

# Main function
main() {
  local forced_theme=${1:-}
  local current_theme

  if [[ -n "$forced_theme" ]]; then
    current_theme="$forced_theme"
  else
    current_theme=$(detect_system_theme)
  fi

  echo "Detected system theme: $current_theme"

  update_kitty_theme "$current_theme"
  update_tmux_theme "$current_theme"
  update_shell_theme "$current_theme"

  echo "Theme switching complete! Restart terminal sessions to see full effect."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
