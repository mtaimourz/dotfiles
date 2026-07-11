# AGENTS.md — maintaining the shared dotfiles

This repository is agent-maintained. Keep it portable, safe, and usable on both
macOS and Linux.

## Source of truth

- Shared home-relative files live under `common/`.
- Do not recreate top-level `mac/`, `ubuntu/`, or per-machine copies.
- Handle real OS differences inside the shared config using runtime detection.
- `install.sh` is the only supported deployment mechanism. It preserves existing
  targets under `~/.dotfiles-backup/` and creates symlinks into `common/`.

## Secrets

- Never commit tokens, API keys, passwords, private keys, or credential-bearing
  remote URLs.
- Credentials live in `~/.config/.keys`.
- Shell secrets and machine-only overrides live in `~/.zshrc.local`, which is not
  part of this repository.
- Before committing, search changed files for secret-like assignments and inspect
  `git diff --cached`.

## Configuration rules

- Neovim uses Lazy, not Packer. Do not commit generated message/log buffers.
- WezTerm uses `wezterm.target_triple` for OS-specific behavior.
- Tmux chooses `pbcopy`/`pbpaste` on macOS and `xclip` on Linux.
- VS Code project launch/tasks files belong in their projects, not this repo.
- Keep `.personal-git-sync` limited to standalone live files. Symlinked application
  directories already write directly into the repository.

## Verify before pushing

```bash
bash -n install.sh
dry=1 ./install.sh
zsh -n common/.zshrc
tmux -f common/.tmux.conf -L dotfiles-check new-session -d
nvim --headless +qa
git status --short
git diff --check
```

Then deploy through the generic personal repo workflow:

```bash
cmd=update msg="dotfiles: <summary>" atuin scripts run personal_git
```
