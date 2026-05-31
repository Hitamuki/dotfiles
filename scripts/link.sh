#!/bin/bash

# ==========================================================
# 設定ファイルのリンク
# dotfiles をホームディレクトリへシンボリックリンクする
# ==========================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DOTFILES_SRC="$DOTFILES_DIR/home"

echo "🔗 Linking dotfiles..."

detect_os() {
  case "$(uname -s)" in
    Darwin) echo "mac" ;;
    Linux) echo "linux" ;;
    *) echo "unknown" ;;
  esac
}

OS=$(detect_os)

link() {
  SRC=$1
  DEST=$2

  if [ -e "$DEST" ] && [ ! -L "$DEST" ]; then
    echo "Backing up $DEST"
    mv "$DEST" "$DEST.backup"
  fi

  ln -sf "$SRC" "$DEST"
}

# .config内にキャッシュや一時ファイルが生成され、git statusが貯まる懸念があるため、個別にシンボリックリンクを作成する
mkdir -p ~/.config/fish
link "$DOTFILES_SRC/.config/fish/config.fish" ~/.config/fish/config.fish
link "$DOTFILES_SRC/.config/fish/fish_plugins" ~/.config/fish/fish_plugins

mkdir -p ~/.config/zsh
link "$DOTFILES_SRC/.config/zsh/.zshrc" ~/.config/zsh/.zshrc
link "$DOTFILES_SRC/.zshenv" ~/.zshenv

mkdir -p ~/.config/sheldon
link "$DOTFILES_SRC/.config/sheldon/plugins.toml" ~/.config/sheldon/plugins.toml

link "$DOTFILES_SRC/.config/mise.toml" ~/.config/mise.toml

link "$DOTFILES_SRC/.config/starship.toml" ~/.config/starship.toml

link "$DOTFILES_SRC/.vimrc" ~/.vimrc
link "$DOTFILES_SRC/.gitconfig" ~/.gitconfig
link "$DOTFILES_SRC/.tmux.conf" ~/.tmux.conf

# ------------------------
# VSCode settings
# ------------------------
VSCODE_SETTINGS_SRC="$DOTFILES_DIR/config/vscode/settings.json"

if [ "$OS" = "mac" ]; then
  VSCODE_SETTINGS_DEST="$HOME/Library/Application Support/Code/User/settings.json"
elif [ "$OS" = "linux" ]; then
  # リモートSSH環境の場合
  if [ -d "$HOME/.vscode-server" ]; then
    VSCODE_SETTINGS_DEST="$HOME/.vscode-server/data/Machine/settings.json"
  else
    # ローカルLinuxの場合
    VSCODE_SETTINGS_DEST="$HOME/.config/Code/User/settings.json"
  fi
fi

if [ -n "$VSCODE_SETTINGS_DEST" ]; then
  mkdir -p "$(dirname "$VSCODE_SETTINGS_DEST")"
  link "$VSCODE_SETTINGS_SRC" "$VSCODE_SETTINGS_DEST"
fi

# ------------------------
# Setup brew and mise
# ------------------------
# Setup brew PATH
if [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -x "$HOME/.linuxbrew/bin/brew" ]; then
  eval "$($HOME/.linuxbrew/bin/brew shellenv)"
fi

# Setup mise if available
if command -v mise &> /dev/null; then
  echo "🔧 Setting up mise..."
  eval "$(mise activate bash)"
fi

# ------------------------
# Install mise
# ------------------------

mise install --verbose

# ------------------------
# Install vim-plug for Vim plugins
# ------------------------
if [ ! -f ~/.vim/autoload/plug.vim ]; then
  echo "Installing vim-plug..."
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

echo "Installing Vim plugins..."
vim -c 'PlugInstall' -c 'qa'

# ------------------------
# Install TPM for tmux if not present
# ------------------------
if [ ! -d ~/.tmux/plugins/tpm ]; then
  echo "Installing TPM (Tmux Plugin Manager)..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# ------------------------
# Install tmux plugins (TPM)
# ------------------------
echo "Installing tmux plugins..."
tmux new-session -d -s install_session
tmux source-file ~/.tmux.conf
tmux run-shell ~/.tmux/plugins/tpm/bin/install_plugins
tmux kill-session -t install_session

# ------------------------
# Install fish plugins (fisher)
# ------------------------
echo "Installing fish plugins..."
fish -c 'curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher'
fish -c 'fisher update'

