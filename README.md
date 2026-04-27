# Dotfiles

Personal macOS dotfiles powered by **Homebrew + GNU Stow**.

## Requirements

- macOS
- [Homebrew](https://brew.sh)
- Git
- Xcode Command Line Tools

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

## How Stow Works

GNU Stow creates symlinks from `~/.dotfiles/.config/*` → `~/.config/*`.

```bash
# Apply all symlinks
stow .

# Remove all symlinks
stow -D .
```

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

## Updating Brewfile

After installing new packages, update the Brewfile snapshot:

```bash
cd ~/.dotfiles
brew bundle dump --force
git add Brewfile
git commit -m "brew: update Brewfile"
git push
```
