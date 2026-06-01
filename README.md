# Dotfiles
Personal macOS dotfiles powered by **Homebrew + GNU Stow**.

## Requirements
- macOS
- [Homebrew](https://brew.sh)
- Git
- Xcode Command Line Tools

> **Note:** This setup uses [Fish shell](https://fishshell.com). After bootstrap, set Fish as your default shell:
> ```bash
> echo $(which fish) | sudo tee -a /etc/shells
> chsh -s $(which fish)
> ```

---

## Bootstrap (Fresh macOS / New Machine)
```bash
git clone git@github.com:chairvus/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

The bootstrap script will automatically:
- Install Homebrew (if not installed)
- Install all packages from `Brewfile`
- Symlink all configs using GNU Stow

---

## Structure
```
~/.dotfiles/
├── .config/
│   ├── fish/        # Fish shell config
│   ├── helix/       # Helix editor config
│   ├── kitty/       # Kitty terminal config
│   ├── starship/    # Starship prompt config
│   ├── yazi/        # Yazi file manager config
│   ├── btop/        # Btop system monitor config
│   └── neofetch/    # Neofetch config
├── Brewfile         # Homebrew packages snapshot
├── bootstrap.sh     # Setup script for fresh install
└── README.md
```

---

## How Stow Works
GNU Stow creates symlinks from `~/.dotfiles/.config/*` → `~/.config/*`.

```bash
# Apply all symlinks
stow .

# Remove all symlinks
stow -D .
```

---

## Managed Configs
| Config | Description |
|--------|-------------|
| `fish` | Fish shell — functions, aliases, environment variables |
| `helix` | Helix editor — languages, LSP, themes |
| `kitty` | Kitty terminal emulator |
| `starship` | Starship cross-shell prompt |
| `yazi` | Yazi terminal file manager |
| `btop` | Btop++ system resource monitor |
| `neofetch` | Neofetch system info display |

---

## Managing Packages (Brewfile)

### Add a specific package manually
```bash
echo 'brew "package-name"' >> ~/.dotfiles/Brewfile
brew install package-name
cd ~/.dotfiles
git add Brewfile
git commit -m "brew: add package-name"
git push
```

### Sync Brewfile after installing multiple packages
After installing several new packages at once, snapshot your current state:
```bash
cd ~/.dotfiles
brew bundle dump --force
git add Brewfile
git commit -m "brew: update Brewfile"
git push
```

### Install all packages from Brewfile (on a new machine)
```bash
brew bundle install --file=~/.dotfiles/Brewfile
```

---

## Updating Dotfiles
Pull latest changes and re-apply symlinks:
```bash
cd ~/.dotfiles
git pull
stow .
```

---

## Uninstall / Remove
Remove all symlinks created by Stow:
```bash
cd ~/.dotfiles
stow -D .
```

To fully remove dotfiles from the machine:
```bash
stow -D .
rm -rf ~/.dotfiles
```

---

## Troubleshooting

**Stow conflict error** — a file already exists at the symlink target:
```bash
# Remove the conflicting file first, then re-run stow
rm ~/.config/<conflicting-file>
stow .
```

**Brewfile out of sync** — packages installed but not in Brewfile:
```bash
brew bundle dump --force
```

**Check what Stow would do without applying:**
```bash
stow --simulate .
```
