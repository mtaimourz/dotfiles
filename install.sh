#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
COMMON="$ROOT/common"
DRY="${dry:-0}"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

say(){ printf '==> %s\n' "$*"; }

link_entry(){
  local source="$1" target="$2" relative="${2#"$HOME"/}"
  if [ -L "$target" ] && [ "$(readlink -f "$target" 2>/dev/null)" = "$(readlink -f "$source")" ]; then
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
while IFS= read -r entry; do
  link_entry "$entry" "$HOME/$(basename "$entry")"
done < <(find "$COMMON" -mindepth 1 -maxdepth 1 ! -name .config -print | sort)

# XDG applications are linked as complete directories. This keeps each app's
# configuration atomic while leaving ~/.config itself under the user's control.
if [ -d "$COMMON/.config" ]; then
  while IFS= read -r entry; do
    link_entry "$entry" "$HOME/.config/$(basename "$entry")"
  done < <(find "$COMMON/.config" -mindepth 1 -maxdepth 1 -print | sort)
fi

say "dotfiles installed from $ROOT"
[ "$DRY" = 1 ] || [ ! -d "$BACKUP" ] || say "previous files preserved in $BACKUP"
