#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
COMMON="$ROOT/common"
OMARCHY="$ROOT/omarchy"
DRY="${dry:-0}"
# only=common or only=omarchy installs one layer. Useful on a machine where the
# shared shell/editor configuration is already set up some other way and only
# the desktop layer is wanted.
ONLY="${only:-all}"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

say(){ printf '==> %s\n' "$*"; }
want(){ [ "$ONLY" = all ] || [ "$ONLY" = "$1" ]; }

link_entry(){
  local source="$1" target="$2" relative="${2#"$HOME"/}"
  if [ -L "$target" ] && [ "$(readlink "$target" 2>/dev/null)" = "$source" ]; then
    say "already linked: ~/$relative"
    return
  fi
  if [ "$DRY" = 1 ]; then
    [ -e "$target" ] || [ -L "$target" ] && say "[dry] would back up: ~/$relative -> $BACKUP/$relative"
    say "[dry] would link: ~/$relative -> $source"
    return
  fi
  mkdir -p "$(dirname "$target")"
  if [ -e "$target" ] || [ -L "$target" ]; then
    mkdir -p "$BACKUP/$(dirname "$relative")"
    mv "$target" "$BACKUP/$relative"
    say "backed up: ~/$relative -> $BACKUP/$relative"
  fi
  ln -s "$source" "$target"
  say "linked: ~/$relative -> $source"
}

[ -d "$COMMON" ] || { echo "ERROR: missing $COMMON" >&2; exit 1; }

# Home-level files such as .zshrc, .tmux.conf, and .vimrc.
if want common; then
for entry in "$COMMON"/.[!.]* "$COMMON"/*; do
  [ -e "$entry" ] || continue
  [ "$(basename "$entry")" = .config ] && continue
  link_entry "$entry" "$HOME/$(basename "$entry")"
done
fi

# XDG applications are linked as complete directories. This keeps each app's
# configuration atomic while leaving ~/.config itself under the user's control.
# VS Code is handled separately because its state directory is machine-local.
if want common && [ -d "$COMMON/.config" ]; then
  for entry in "$COMMON/.config"/.[!.]* "$COMMON/.config"/*; do
    [ -e "$entry" ] || continue
    [ "$(basename "$entry")" = Code ] && continue
    link_entry "$entry" "$HOME/.config/$(basename "$entry")"
  done
fi

# VS Code uses different user-data roots on macOS and Linux. Link only portable
# user files so globalStorage, workspaceStorage, and other local state stay local.
if want common && [ -d "$COMMON/.config/Code/User" ]; then
  case "$(uname -s)" in
    Darwin) vscode_user="$HOME/Library/Application Support/Code/User" ;;
    *) vscode_user="$HOME/.config/Code/User" ;;
  esac
  for entry in "$COMMON/.config/Code/User"/.[!.]* "$COMMON/.config/Code/User"/*; do
    [ -f "$entry" ] || continue
    link_entry "$entry" "$vscode_user/$(basename "$entry")"
  done
fi

# Omarchy desktop configuration: Hyprland, the Omarchy shell, terminals, and
# the hypr-* helper scripts. Linked file by file rather than by directory,
# because ~/.config/hypr and ~/.config/omarchy are Omarchy's own directories --
# they hold plenty we do not track, and monitors.lua in particular is
# per-display and stays machine-local.
if want omarchy && [ -d "$OMARCHY" ]; then
  if command -v omarchy >/dev/null 2>&1; then
    while IFS= read -r entry; do
      link_entry "$entry" "$HOME/${entry#"$OMARCHY"/}"
    done < <(find "$OMARCHY" -type f -not -name 'setup.sh' -not -name 'README.md' | sort)
  else
    say "skipping omarchy/: not an Omarchy machine"
  fi
fi

say "dotfiles installed from $ROOT"
[ "$DRY" = 1 ] || [ ! -d "$BACKUP" ] || say "previous files preserved in $BACKUP"
if want omarchy && [ -d "$OMARCHY" ] && command -v omarchy >/dev/null 2>&1; then
  say "next: ./omarchy/setup.sh  (packages, theme, dock plugin, git identity)"
fi
