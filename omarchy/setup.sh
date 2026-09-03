#!/usr/bin/env bash
# Everything about an Omarchy machine that is not a file: packages, the theme,
# the shell plugins, and the git identity. install.sh links the configuration;
# this reproduces the state those files assume.
#
# Idempotent -- every step checks before acting, so re-running is a no-op.
#
#   ./setup.sh          apply
#   dry=1 ./setup.sh    show what would happen
set -euo pipefail

DRY="${dry:-0}"

say(){ printf '==> %s\n' "$*"; }
run(){
  if [ "$DRY" = 1 ]; then printf '    [dry] %s\n' "$*"; else "$@"; fi
}

command -v omarchy >/dev/null || { echo "ERROR: not an Omarchy machine" >&2; exit 1; }

# --- packages -------------------------------------------------------------
# Only what Omarchy's own base set does not already install. Kept as two lists
# because AUR packages go through a different installer.
REPO_PACKAGES=(flatpak kdeconnect)
AUR_PACKAGES=(brave-bin google-chrome visual-studio-code-bin nordvpn-bin proton-vpn-gtk-app voxtype-bin)

say "packages (repo)"
if omarchy pkg missing "${REPO_PACKAGES[@]}" >/dev/null 2>&1; then
  run omarchy pkg add "${REPO_PACKAGES[@]}"
else
  say "    all present"
fi

say "packages (AUR)"
for pkg in "${AUR_PACKAGES[@]}"; do
  if pacman -Qq "$pkg" >/dev/null 2>&1; then
    say "    $pkg present"
  else
    run omarchy pkg aur add "$pkg"
  fi
done

# --- theme ----------------------------------------------------------------
THEME_NAME="Forest Night"
THEME_REPO="https://github.com/ForrestKnight/omarchy-forest-night-theme"

say "theme: $THEME_NAME"
if omarchy theme list 2>/dev/null | grep -qxF "$THEME_NAME"; then
  say "    already installed"
else
  run omarchy theme install "$THEME_REPO"
fi
[ "$(omarchy theme current 2>/dev/null)" = "$THEME_NAME" ] &&
  say "    already active" || run omarchy theme set "$THEME_NAME"

# --- shell plugins --------------------------------------------------------
# The dock. shell.json carries its settings and the pinned items; this only
# installs the plugin itself, which lives in git rather than in the config.
#
# Deliberately NOT symlinked from this repo: the shell watches
# ~/.config/omarchy/plugins with a non-recursive-into-symlinks inotify watch,
# so a linked plugin directory never hot-reloads.
say "plugin: rdf.dock"
if omarchy plugin list 2>/dev/null | grep -q '^rdf\.dock'; then
  say "    already installed"
else
  run omarchy plugin add https://github.com/Robindfuller/omarchy-dock --enable --yes
fi

# --- git identity ---------------------------------------------------------
# ~/.config/git/config is an Omarchy template, so it is not linked from here;
# only the identity is ours, and this writes just that.
GIT_NAME="mtaimourz"
GIT_EMAIL="taimour.rkt@gmail.com"

say "git identity"
[ "$(git config --global user.name  || true)" = "$GIT_NAME"  ] &&
  say "    name set"  || run git config --global user.name  "$GIT_NAME"
[ "$(git config --global user.email || true)" = "$GIT_EMAIL" ] &&
  say "    email set" || run git config --global user.email "$GIT_EMAIL"

say "done"
[ "$DRY" = 1 ] || say "reload the desktop with: omarchy restart shell && hyprctl reload"
