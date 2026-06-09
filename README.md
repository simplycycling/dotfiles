# dotfiles

## Apps covered

**Shell & Prompt**
- **zsh** — `.zshrc`, `.zalias`, `.zfunctions`, platform-specific local configs
- **Powerlevel10k** — `.p10k.zsh`
- **zsh-autosuggestions**
- **zsh-syntax-highlighting**

**Terminal & Multiplexer**
- **WezTerm** — `.wezterm.lua` (font, opacity, tab bar)
- **tmux** — `.tmux.conf` (plugins: tpm, vim-tmux-navigator, themepack, resurrect, continuum)

**Window Management (macOS)**
- **AeroSpace** — `.config/aerospace/aerospace.toml`

**Editor**
- **Neovim** — `.config/nvim/` (lazy.nvim + vim.pack, LSP via Mason, Telescope, Treesitter, ~20 plugins)

**Version Control**
- **Git** — `.gitconfig`, `gitconfig.local.macos`, `gitconfig.local.linux` (SSH signing, default branch)
- **GitHub CLI (`gh`)** — `.config/gh/`
- **lazygit** — aliased in `.zalias`

**Secrets & Auth**
- **1Password** — `.config/1Password/ssh/agent.toml` (SSH agent, Private vault)
- **1Password CLI (`op`)** — `.config/op/config`

**Containers**
- **Podman** — `.zfunctions` (`sandbox` function for isolated node containers)
- **lazydocker** — aliased in `.zalias`

**Kubernetes**
- **krew** — PATH export in `.zshrc`
- **labctl** (iximiuz Labs CLI) — PATH + completion in `zshrc.local.macos`

**System Monitoring**
- **htop** — `.config/htop/htoprc`

**File Listing**
- **eza** — aliased in `.zshrc` and `.zalias`

**Notes / PKM**
- **Obsidian** (vault at `~/Documents/simplycycling`) — aliases and `bin/on` (new inbox note), `bin/og` (organize zettelkasten by tag)

**macOS System**
- **macOS defaults** — `.osx` (Dock, keyboard repeat, smart quotes)