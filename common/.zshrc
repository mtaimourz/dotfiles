# ~/.zshrc — portable clone of Taimour's Mac shell (works on macOS + Ubuntu).
# Secrets live in ~/.zshrc.local (never synced). Prompt config is ~/.p10k.zsh.

# --- powerlevel10k instant prompt (keep near top) ---
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

HYPHEN_INSENSITIVE="true"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
ZSH_DISABLE_COMPFIX="true"
source "$ZSH/oh-my-zsh.sh"

# --- user-controlled SSH agent ---
export SSH_AUTH_SOCK="$HOME/.ssh/agent/agent.sock"
ssh-add -l >/dev/null 2>&1
if [[ $? -eq 2 ]]; then
  mkdir -p "$HOME/.ssh/agent"
  rm -f "$SSH_AUTH_SOCK"
  ssh-agent -a "$SSH_AUTH_SOCK" >/dev/null
fi

# exact same prompt as the Mac
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- aliases ---
alias hgrep="history | grep"
alias playground="cd ~/dev/playground"
alias commands="cd ~/dev/myrepos/commands"
alias leetcode="cd ~/dev/myrepos/Leetcode"
alias gb='git branch --sort=-committerdate'
alias gl='git log --all --graph --pretty=format:"%C(auto)%h %C(blue)%aN %C(magenta)%ad%C(auto)%d %Creset%s" --date=format:"%Y-%m-%d %H:%M"'
alias gll='git log --first-parent --pretty=format:"%C(auto)%h %C(magenta)%ad%C(auto)%d %C(blue)%aN %Creset%s" --date=format:"%Y-%m-%d %H:%M"'

# --- version managers (guarded so it's safe on any machine) ---
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

export PYENV_ROOT="$HOME/.pyenv"
[ -d "$PYENV_ROOT/bin" ] && export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv >/dev/null && eval "$(pyenv init --path)"

[ -s "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

export BUN_INSTALL="$HOME/.bun"
[ -d "$BUN_INSTALL/bin" ] && export PATH="$BUN_INSTALL/bin:$PATH"

export PATH="$HOME/.local/bin:$PATH"   # rb + user bins

# --- atuin (history + scripts) + robust up/down history search ---
# This block fixes the Ubuntu "up arrow doesn't show history" problem: after
# atuin initialises we FORCE-bind both cursor-up escape sequences (normal ^[[A
# and application-mode ^[OA, plus the terminfo values) to atuin's search widget.
zmodload zsh/terminfo 2>/dev/null || true
[ -f "$HOME/.atuin/bin/env" ] && . "$HOME/.atuin/bin/env"
if command -v atuin >/dev/null; then
  eval "$(atuin init zsh)"
  _have_widget() { zle -la 2>/dev/null | grep -qx "$1"; }
  if _have_widget atuin-up-search; then
    bindkey '^[[A' atuin-up-search
    bindkey '^[OA' atuin-up-search
    [ -n "${terminfo[kcuu1]:-}" ] && bindkey "${terminfo[kcuu1]}" atuin-up-search
  else
    bindkey '^[[A' up-line-or-search; bindkey '^[OA' up-line-or-search
  fi
  if _have_widget atuin-down-search; then
    bindkey '^[[B' atuin-down-search
    bindkey '^[OB' atuin-down-search
    [ -n "${terminfo[kcud1]:-}" ] && bindkey "${terminfo[kcud1]}" atuin-down-search
  else
    bindkey '^[[B' down-line-or-search; bindkey '^[OB' down-line-or-search
  fi
fi

# --- secrets & machine-specific overrides (NOT synced/committed) ---
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
