#!/bin/bash

# ==========================================================
# 初期セットアップ
# 開発環境を初期構築するスクリプト
#
# 対応OS:
#   macOS / Linux
# ==========================================================

set -e

detect_os() {
  case "$(uname -s)" in
    Darwin) echo "mac" ;;
    Linux) echo "linux" ;;
    *) echo "unknown" ;;
  esac
}

OS=$(detect_os)

echo "🧠 Bootstrap for $OS"

# ------------------------
# Homebrew install
# ------------------------
install_brew_linux() {
  # sudo 権限があるか確認（パスワードをキャッシュ）
  echo "🔑 sudo パスワードの確認..."
  if ! sudo -v; then
    echo "❌ sudo 権限がありません。"
    echo "   ユーザーを sudo グループに追加してください："
    echo ""
    echo "       su - && usermod -aG sudo $(whoami)"
    echo ""
    exit 1
  fi

  echo "🍺 Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # パスを追加（インストール場所に応じて分岐）
  if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  elif [ -f "$HOME/.linuxbrew/bin/brew" ]; then
    echo 'eval "$($HOME/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
    eval "$($HOME/.linuxbrew/bin/brew shellenv)"
  fi

  brew bundle --file=./Brewfile.Linux
}

if ! command -v brew &> /dev/null; then
  if [ "$OS" = "linux" ]; then
    install_brew_linux
  else
    echo "🍺 Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
fi

# ------------------------
# Brewfile install
# ------------------------
if command -v brew &>/dev/null; then
  if [ "$OS" = "mac" ]; then
    brew bundle --file=./Brewfile
  elif [ "$OS" = "linux" ]; then
    brew bundle --file=./Brewfile.Linux
  fi
fi

# ------------------------
# VSCode extensions
# ------------------------
if command -v code &> /dev/null; then
  # コメント行を除去して拡張機能IDのみを抽出
  grep -v '^//' config/vscode/extensions.txt | sed 's|//.*||' | xargs -n 1 code --install-extension || true
fi
