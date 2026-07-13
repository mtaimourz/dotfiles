# dotfiles

One shared configuration for macOS and Linux. Platform differences live inside
the relevant configuration file or the installer and are detected at runtime;
there are no duplicated `mac/` and `ubuntu/` trees.

## Layout

```text
common/
  .config/
    Code/User/  shared VS Code settings and platform-aware keybindings
    nvim/       shared Neovim configuration (Lazy + Mason)
    wezterm/    shared WezTerm configuration
    zed/        shared Zed keymap
  .tmux.conf
  .vimrc
  .zshrc
install.sh      idempotent symlink installer
```

Secrets and machine-only overrides do not belong here. Put shell overrides in
`~/.zshrc.local` and credentials in `~/.config/.keys`.

## Install

Preview without changing anything:

```bash
dry=1 ./install.sh
```

Install shared configuration:

```bash
./install.sh
```

Existing targets are moved into a timestamped directory under
`~/.dotfiles-backup/` before symlinks are created. Running the installer again is
safe.

VS Code stores user configuration under `~/.config/Code/User` on Linux and
`~/Library/Application Support/Code/User` on macOS. The installer detects the
platform and links the shared settings and keybindings into the correct location
without replacing VS Code's machine-local state.

## Agent workflow

Run from this repository after making changes:

```bash
cmd=update msg="dotfiles: describe the change" atuin scripts run personal_git
```

The optional `.personal-git-sync` manifest copies live standalone configuration
files into `common/` before the commit. Application directories installed as
symlinks, such as Neovim, are already edited directly in the repository.
