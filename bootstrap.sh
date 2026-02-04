#!/usr/bin/env bash
set -e

echo "==> Xcode Command Line Tools"
xcode-select --install || true

echo "==> Homebrew packages"
brew bundle

echo "==> Dotfiles"
cd ~/.dotfiles
stow .

echo "==> Done"

