#!/bin/bash

# ==========================================================
# 設定ファイルのリンク
# dotfiles をホームディレクトリへシンボリックリンクする
# ==========================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DOTFILES_SRC="$DOTFILES_DIR/home"

echo "🔗 Linking dotfiles..."

link() {
  SRC=$1
  DEST=$2

  if [ -e "$DEST" ] && [ ! -L "$DEST" ]; then
    echo "Backing up $DEST"
    mv "$DEST" "$DEST.backup"
  fi

  ln -sf "$SRC" "$DEST"
}

link "$DOTFILES_SRC/.config" ~/.config
link "$DOTFILES_SRC/.tmux.conf" ~/.tmux.conf
link "$DOTFILES_SRC/.vimrc" ~/.vimrc
link "$DOTFILES_SRC/.gitconfig" ~/.gitconfig

