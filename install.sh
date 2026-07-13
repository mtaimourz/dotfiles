#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
COMMON="$ROOT/common"
DRY="${dry:-0}"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

say(){ printf '==> %s\n' "$*"; }

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
for entry in "$COMMON"/.[!.]* "$COMMON"/*; do
  [ -e "$entry" ] || continue
  [ "$(basename "$entry")" = .config ] && continue
  link_entry "$entry" "$HOME/$(basename "$entry")"
done

# XDG applications are linked as complete directories. This keeps each app's
# configuration atomic while leaving ~/.config itself under the user's control.
# VS Code is handled separately because its state directory is machine-local.
if [ -d "$COMMON/.config" ]; then
  for entry in "$COMMON/.config"/.[!.]* "$COMMON/.config"/*; do
    [ -e "$entry" ] || continue
    [ "$(basename "$entry")" = Code ] && continue
    link_entry "$entry" "$HOME/.config/$(basename "$entry")"
  done
fi

# VS Code uses different user-data roots on macOS and Linux. Link only portable
# user files so globalStorage, workspaceStorage, and other local state stay local.
if [ -d "$COMMON/.config/Code/User" ]; then
  case "$(uname -s)" in
    Darwin) vscode_user="$HOME/Library/Application Support/Code/User" ;;
    *) vscode_user="$HOME/.config/Code/User" ;;
  esac
  for entry in "$COMMON/.config/Code/User"/.[!.]* "$COMMON/.config/Code/User"/*; do
    [ -f "$entry" ] || continue
    link_entry "$entry" "$vscode_user/$(basename "$entry")"
  done
fi

say "dotfiles installed from $ROOT"
[ "$DRY" = 1 ] || [ ! -d "$BACKUP" ] || say "previous files preserved in $BACKUP"
