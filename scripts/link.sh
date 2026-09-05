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

# WSL2 判定（WSL特有の分岐に使用する）
if [ "$OS" = "linux" ] && grep -qi microsoft /proc/version 2>/dev/null; then
  IS_WSL=1
else
  IS_WSL=0
fi

link() {
  SRC=$1
  DEST=$2

  # 既存の実ファイル・シンボリックリンクは削除し、リポジトリへのシンボリックリンクを強制する
  # （mise 等が実ファイルを生成してリンクが上書きされるケースでも、常にリポジトリを正とする）
  rm -rf "$DEST"
  ln -s "$SRC" "$DEST"
}

# .config内にキャッシュや一時ファイルが生成され、git statusが貯まる懸念があるため、個別にシンボリックリンクを作成する
mkdir -p ~/.config/fish
link "$DOTFILES_SRC/.config/fish/config.fish" ~/.config/fish/config.fish
link "$DOTFILES_SRC/.config/fish/fish_plugins" ~/.config/fish/fish_plugins

mkdir -p ~/.config/zsh
link "$DOTFILES_SRC/.config/zsh/.zshrc" ~/.config/zsh/.zshrc
link "$DOTFILES_SRC/.zshenv" ~/.zshenv

link "$DOTFILES_SRC/.bashrc" ~/.bashrc

mkdir -p ~/.config/bash
link "$DOTFILES_SRC/.config/bash/.bashrc" ~/.config/bash/.bashrc

mkdir -p ~/.config/sheldon
link "$DOTFILES_SRC/.config/sheldon/plugins.toml" ~/.config/sheldon/plugins.toml

link "$DOTFILES_SRC/.config/mise.toml" ~/.config/mise.toml

link "$DOTFILES_SRC/.config/starship.toml" ~/.config/starship.toml

mkdir -p ~/.config/alacritty
link "$DOTFILES_SRC/.config/alacritty/alacritty.toml" ~/.config/alacritty/alacritty.toml

mkdir -p ~/.config/herdr
link "$DOTFILES_SRC/.config/herdr/config.toml" ~/.config/herdr/config.toml

link "$DOTFILES_SRC/.vimrc" ~/.vimrc
link "$DOTFILES_SRC/.gitconfig" ~/.gitconfig
link "$DOTFILES_SRC/.tmux.conf" ~/.tmux.conf

# ------------------------
# Git のユーザー情報
# ------------------------
# 個人情報をリポジトリ管理下に置かないため、~/.gitconfig（= home/.gitconfig）は
# ~/.gitconfig.local を include するだけにしている。
# ここではリポジトリ管理外の ~/.gitconfig.local に雛形を生成する（既存なら変更しない）。
GITCONFIG_LOCAL="$HOME/.gitconfig.local"
if [ -e "$GITCONFIG_LOCAL" ]; then
  echo "✅ $GITCONFIG_LOCAL は既に存在するため作成をスキップしました"
else
  cat > "$GITCONFIG_LOCAL" <<'GITCONFIG_LOCAL_EOF'
# ==========================================================
# Git のマシン・個人ごとの設定
#
# このファイルはリポジトリ管理外（dotfiles では追跡しない）。
# 共通設定は ~/.gitconfig（dotfiles の home/.gitconfig へのリンク）が持ち、
# その末尾から include している。後から読み込まれるため、
# ここに書いた設定は共通設定を上書きする。
#
# ユーザー情報のほか、マシンによって変わる設定
# （認証ヘルパー、署名鍵、業務用リポジトリ向けの設定など）もここに書く。
# ==========================================================

[user]
  name =
  email =
GITCONFIG_LOCAL_EOF
  echo "📝 $GITCONFIG_LOCAL を作成しました。user.name / user.email を記入してください。"
fi

# .claude内にcredentialsやsession等のランタイムファイルが生成されるため、設定ファイルのみ個別にシンボリックリンクを作成する
mkdir -p ~/.claude
link "$DOTFILES_SRC/.claude/settings.json" ~/.claude/settings.json
link "$DOTFILES_SRC/.claude/statusline.sh" ~/.claude/statusline.sh

# ------------------------
# VSCode settings
# ------------------------
VSCODE_SETTINGS_SRC="$DOTFILES_DIR/config/vscode/settings.json"

if [ "$OS" = "mac" ]; then
  VSCODE_SETTINGS_DEST="$HOME/Library/Application Support/Code/User/settings.json"
elif [ "$OS" = "linux" ]; then
  # リモート（WSL2 / SSH）環境の場合
  if [ -d "$HOME/.vscode-server" ]; then
    VSCODE_SETTINGS_DEST="$HOME/.vscode-server/data/Machine/settings.json"
  else
    # ローカルLinuxの場合
    VSCODE_SETTINGS_DEST="$HOME/.config/Code/User/settings.json"

    # ~/.vscode-server は VSCode で初めてリモート接続したときに生成されるため、
    # WSL2 の初回セットアップでは必ずこちら（ローカルLinux用のパス）が選ばれる
    if [ "$IS_WSL" = "1" ]; then
      echo "⚠️  ~/.vscode-server が無いため、VSCode設定をローカルLinux用のパスにリンクしました。"
      echo "   WSL2 では VSCode から一度 WSL に接続した後、'make link' を再実行してください。"
    fi
  fi
fi

if [ -n "$VSCODE_SETTINGS_DEST" ]; then
  mkdir -p "$(dirname "$VSCODE_SETTINGS_DEST")"
  link "$VSCODE_SETTINGS_SRC" "$VSCODE_SETTINGS_DEST"
fi

VSCODE_ARGV_SRC="$DOTFILES_DIR/config/vscode/argv.json"
VSCODE_ARGV_DEST="$HOME/.vscode/argv.json"

mkdir -p "$(dirname "$VSCODE_ARGV_DEST")"
link "$VSCODE_ARGV_SRC" "$VSCODE_ARGV_DEST"

# ------------------------
# Setup brew and mise
# ------------------------
# Setup brew PATH
if [ -x "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/usr/local/bin/brew" ]; then
  eval "$(/usr/local/bin/brew shellenv)"
elif [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
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
if command -v mise &> /dev/null; then
  mise install --verbose
else
  echo "⚠️  mise が見つかりません。Brewfile のインストールを確認してください（bootstrap.sh を先に実行してください）。"
fi

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

