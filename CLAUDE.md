# CLAUDE.md

## Dotfiles setup

This repo (github.com/simplycycling/dotfiles) is the source of truth for Roger's dotfiles.

### Workflow

1. Edit files here in `~/src/dotfiles`
2. Commit and push to GitHub
3. On the target machine, run the Ansible playbook — it clones the repo to `~/Documents/dotfiles` and symlinks everything into `~`

### Ansible

Managed by Jeff Geerling's `ansible-role-dotfiles`, configured in `~/src/ansible/`:

- `runit.yml` — the playbook to run
- `ansible-role-dotfiles/defaults/main.yml` — defines which files get symlinked

Run with:
```sh
cd ~/src/ansible && ansible-playbook runit.yml
```

### What gets symlinked

The following are symlinked from `~/Documents/dotfiles/` into `~/`:

- `.config` (entire directory — includes nvim, aerospace, gh, htop, etc.)
- `.gitconfig`
- `.p10k.zsh`
- `.tmux.conf`
- `.wezterm.lua`
- `.zalias`
- `.zshrc`
- `.claude/settings.json`
- `.claude/plugins/devops-toolkit`
- `.claude/plugins/.claude-plugin/marketplace.json`
- `bin/on`
- `bin/og`

### Important note

`~/.config/nvim` is **not** a direct symlink — the entire `~/.config` directory is symlinked. Any files created directly in `~/.config/nvim` on the live system (e.g. `nvim-pack-lock.json`) will live in `~/Documents/dotfiles/.config/nvim`, not in `~/src/dotfiles`. To version control them, copy them to `~/src/dotfiles/.config/nvim` and commit.
