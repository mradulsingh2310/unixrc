# unixrc

My terminal development environment configuration for macOS.

**Stack:** Ghostty + Tmux + Neovim (LazyVim)

**Theme:** Catppuccin Mocha with transparent backgrounds

---

## Installation

### Prerequisites
- [Ghostty](https://ghostty.org/) terminal emulator
- [tmux](https://github.com/tmux/tmux) with [TPM](https://github.com/tmux-plugins/tpm)
- [Neovim](https://neovim.io/) 0.9+
- [JetBrainsMono Nerd Font](https://www.nerdfonts.com/)

### Setup

```bash
# Clone the repo
git clone https://github.com/mradulsingh2310/unixrc.git ~/unixrc

# Symlink configs
ln -sf ~/unixrc/ghostty/config ~/.config/ghostty/config
ln -sf ~/unixrc/nvim ~/.config/nvim
ln -sf ~/unixrc/tmux/tmux.conf ~/.tmux.conf

# Install tmux plugins (open tmux then press prefix + I)
tmux source ~/.tmux.conf
```

---

## Keybindings Reference

### Legend
| Symbol | Key |
|--------|-----|
| `⌘` | Cmd (Super) |
| `⌥` | Option (Alt) |
| `⌃` | Ctrl |
| `⇧` | Shift |
| `prefix` | Ctrl+a (tmux prefix) |

---

## Ghostty Keybindings

Ghostty is configured to auto-start tmux and translate macOS keybindings to terminal sequences.

### Window/Pane Management

| Keybinding | Action |
|------------|--------|
| `⌘ + t` | New tmux window |
| `⌘ + ⇧ + t` | New Ghostty window (separate terminal) |
| `⌘ + w` | Close tmux pane |
| `⌘ + d` | Vertical split |
| `⌘ + ⇧ + d` | Horizontal split |
| `⌘ + f` | Toggle fullscreen |
| `⌘ + =` | Zoom/maximize current pane |
| `⌘ + 0` | Reset pane layout (tiled) |

### Window Navigation

| Keybinding | Action |
|------------|--------|
| `⌘ + 1-9` | Switch to tmux window 1-9 |
| `⌘ + ⇧ + ]` | Next tmux window |
| `⌘ + ⇧ + [` | Previous tmux window |

### Pane Resize

| Keybinding | Action |
|------------|--------|
| `⌘ + ⌥ + ←` | Resize pane left |
| `⌘ + ⌥ + →` | Resize pane right |
| `⌘ + ⌥ + ↑` | Resize pane up |
| `⌘ + ⌥ + ↓` | Resize pane down |

### Neovim Commands (via escape sequences)

| Keybinding | Action |
|------------|--------|
| `⌘ + s` | Save file |
| `⌘ + z` | Undo |
| `⌘ + ⇧ + z` | Redo |
| `⌘ + /` | Toggle comment |
| `⌘ + p` | Find files (Telescope) |
| `⌘ + ⇧ + p` | Command palette |
| `⌘ + b` | Toggle file explorer (Neo-tree) |
| `⌘ + n` | New buffer |
| `⌘ + o` | Open file |
| `⌘ + ,` | Open config |
| `⌘ + h/j/k/l` | Navigate panes |

---

## Tmux Keybindings

**Prefix:** `Ctrl + a`

### Session/Window Management

| Keybinding | Action |
|------------|--------|
| `prefix + c` | New window (preserves path) |
| `prefix + \|` | Vertical split (preserves path) |
| `prefix + -` | Horizontal split (preserves path) |
| `prefix + x` | Close pane |
| `prefix + z` | Zoom/unzoom pane |
| `prefix + E` | Reset to tiled layout |
| `prefix + r` | Reload config |

### Pane Navigation (Vim-style)

| Keybinding | Action |
|------------|--------|
| `prefix + h` | Select pane left |
| `prefix + j` | Select pane down |
| `prefix + k` | Select pane up |
| `prefix + l` | Select pane right |
| `⌃ + h/j/k/l` | Seamless navigation (works with Neovim splits) |

### Window Switching

| Keybinding | Action |
|------------|--------|
| `⌥ + 1-5` | Switch to window 1-5 |
| `prefix + n` | Next window |
| `prefix + p` | Previous window |

### Pane Resize

| Keybinding | Action |
|------------|--------|
| `⌃ + ↑` | Resize pane up |
| `⌃ + ↓` | Resize pane down |
| `⌃ + ←` | Resize pane left |
| `⌃ + →` | Resize pane right |

### Copy Mode

| Keybinding | Action |
|------------|--------|
| Mouse drag | Select and copy to clipboard |

### Installed Plugins

- **tpm** - Tmux Plugin Manager
- **tmux-sensible** - Sensible defaults
- **vim-tmux-navigator** - Seamless pane navigation with Neovim

---

## Neovim Keybindings (LazyVim)

Based on [LazyVim](https://www.lazyvim.org/) with custom extensions.

### General

| Keybinding | Action |
|------------|--------|
| `<Space>` | Leader key |
| `<leader>ua` | Toggle auto-save |
| `⌃ + p` | Find files (Telescope) |

### File Navigation

| Keybinding | Action |
|------------|--------|
| `<leader>e` | Toggle file explorer |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Find buffers |
| `<leader>fr` | Recent files |

### Window Navigation

| Keybinding | Action |
|------------|--------|
| `⌃ + h` | Navigate left (works across tmux panes) |
| `⌃ + j` | Navigate down |
| `⌃ + k` | Navigate up |
| `⌃ + l` | Navigate right |

### Window Resize

| Keybinding | Action |
|------------|--------|
| `⌃ + ↑` | Increase window height |
| `⌃ + ↓` | Decrease window height |
| `⌃ + ←` | Decrease window width |
| `⌃ + →` | Increase window width |

### Editing (Insert Mode - Mac-style)

| Keybinding | Action |
|------------|--------|
| `⌥ + Backspace` | Delete word backwards |
| `⌥ + Delete` | Delete word forwards |
| `⌥ + ←/→` | Move by word |
| `⌘ + ←/→` | Move to beginning/end of line |

### Quickfix

| Keybinding | Action |
|------------|--------|
| `]q` | Next quickfix |
| `[q` | Previous quickfix |
| `<leader>qo` | Open quickfix |
| `<leader>qc` | Close quickfix |
| `<leader>qx` | Clear quickfix |
| `dd` (in quickfix) | Delete entry |

### LSP (Space + l)

| Keybinding | Action |
|------------|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `gI` | Go to implementation |
| `K` | Hover documentation |
| `<leader>ca` | Code action |
| `<leader>cr` | Rename symbol |
| `<leader>cf` | Format file |

### Git (Space + g)

| Keybinding | Action |
|------------|--------|
| `<leader>gg` | Lazygit |
| `<leader>gf` | Git files |
| `<leader>gc` | Git commits |
| `<leader>gb` | Git blame |
| `]h` | Next hunk |
| `[h` | Previous hunk |

### Buffers (Space + b)

| Keybinding | Action |
|------------|--------|
| `<leader>bd` | Delete buffer |
| `<leader>bo` | Delete other buffers |
| `<S-h>` | Previous buffer |
| `<S-l>` | Next buffer |

### Which-Key

Press `<Space>` and wait to see all available keybindings.

---

## Installed Neovim Plugins

### Core
- **LazyVim** - Neovim distribution
- **lazy.nvim** - Plugin manager

### UI
- **catppuccin** - Color scheme (Mocha, transparent)
- **neo-tree.nvim** - File explorer
- **which-key.nvim** - Keybinding hints

### Editor
- **auto-save.nvim** - Automatic file saving
- **vim-tmux-navigator** - Seamless tmux/neovim navigation
- **telescope.nvim** - Fuzzy finder

### LSP
- **nvim-lspconfig** - LSP configuration
- **nvim-jdtls** - Java LSP with enhanced completion
- **nvim-cmp** - Completion engine

### Languages
- Java (jdtls with Spotless formatting)
- Protocol Buffers (protols)

---

## Auto-Sync

Config changes are **automatically synced to GitHub** using macOS `launchd`.

### How it works
- `launchd` watches your config files for changes
- When a file changes, `sync.sh` copies it to `~/unixrc`
- Changes are auto-committed and pushed to GitHub
- 10-second throttle prevents rapid-fire triggers

### Watched paths
- `~/.config/ghostty/config`
- `~/.tmux.conf`
- `~/.config/nvim/init.lua`
- `~/.config/nvim/lua/config/*`
- `~/.config/nvim/lua/plugins/*`

### Managing the sync agent

```bash
# Check status
launchctl list | grep unixrc

# Stop auto-sync
launchctl unload ~/Library/LaunchAgents/com.mradulsingh.unixrc-sync.plist

# Start auto-sync
launchctl load ~/Library/LaunchAgents/com.mradulsingh.unixrc-sync.plist

# View sync log
tail -f ~/unixrc/.sync.log

# Manual sync (if needed)
~/unixrc/sync.sh
```

### Modifying the sync behavior

All sync files are in the repo:
- `sync.sh` - The sync logic
- `com.mradulsingh.unixrc-sync.plist` - launchd configuration

After editing either file, reinstall the agent:
```bash
~/unixrc/install-sync.sh
```

### GPG Signing

Auto-sync commits are GPG signed using a **passwordless key** (required for launchd automation).

To generate a new passwordless GPG key:
```bash
# Create key config
cat > /tmp/gpg-key.txt << 'EOF'
%no-protection
Key-Type: RSA
Key-Length: 4096
Name-Real: Your Name (autosync)
Name-Email: your-email@example.com
Expire-Date: 0
%commit
EOF

# Generate key
gpg --batch --generate-key /tmp/gpg-key.txt

# Get key ID
gpg --list-keys --keyid-format SHORT your-email@example.com

# Export and add to GitHub (https://github.com/settings/keys)
gpg --armor --export YOUR_KEY_ID

# Configure repo to use the key
cd ~/unixrc
git config user.signingkey YOUR_KEY_ID
git config commit.gpgsign true
```

---

## Configuration Files

```
unixrc/
├── ghostty/
│   └── config          # Ghostty terminal config
├── nvim/
│   ├── init.lua        # Entry point
│   └── lua/
│       ├── config/
│       │   ├── autocmds.lua   # Auto commands
│       │   ├── keymaps.lua    # Custom keybindings
│       │   ├── lazy.lua       # Plugin manager setup
│       │   └── options.lua    # Vim options
│       └── plugins/
│           ├── autosave.lua
│           ├── colorscheme.lua
│           ├── dashboard.lua
│           ├── java.lua
│           ├── noice.lua
│           ├── proto.lua
│           ├── search.lua
│           ├── tmux-navigator.lua
│           └── which-key.lua
├── tmux/
│   └── tmux.conf       # Tmux configuration
├── sync.sh             # Auto-sync script (triggered by launchd)
├── install-sync.sh     # Reinstall launchd agent after changes
└── com.mradulsingh.unixrc-sync.plist  # launchd configuration
```

---

## Features

### Seamless Navigation
`Ctrl + h/j/k/l` works across both tmux panes and Neovim splits without any prefix.

### macOS-Native Keybindings
Use familiar `Cmd + s`, `Cmd + z`, `Cmd + p` shortcuts in Neovim through Ghostty's escape sequence translation.

### Auto-Save
Files are automatically saved on:
- Leaving insert mode
- Text changes (with 1s debounce)
- Leaving buffer or focus

### Java Development
- Spotless auto-formatting on save
- Enhanced import organization
- Static member favorites for testing frameworks

---

## License

MIT
