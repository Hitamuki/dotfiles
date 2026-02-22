#!/bin/bash

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
if ! command -v brew &> /dev/null; then
  echo "🍺 Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Linux path追加
  if [ "$OS" = "linux" ]; then
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.profile
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
fi

# ------------------------
# Brewfile install
# ------------------------
if [ "$OS" = "mac" ]; then
  brew bundle --file=./Brewfile
elif [ "$OS" = "linux" ]; then
  brew bundle --file=./Brewfile.Linux
fi

# ------------------------
# mise
# ------------------------
if ! command -v mise &> /dev/null; then
  curl https://mise.run | sh
fi

mise install

# ------------------------
# VSCode extensions
# ------------------------
if command -v code &> /dev/null; then
  xargs -n 1 code --install-extension < config/vscode/extensions.txt || true
fi

