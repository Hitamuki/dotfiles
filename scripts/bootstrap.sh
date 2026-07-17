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
    echo "🔑 sudo パスワードの確認..."
    if ! sudo -v; then
      echo "❌ sudo 権限がありません。管理者ユーザーで実行してください。"
      exit 1
    fi

    echo "🍺 Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # インストール直後の同一シェルでも brew を使えるように PATH を通す
    if [ -x "/opt/homebrew/bin/brew" ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x "/usr/local/bin/brew" ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
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
# ble.sh (Bash Line Editor)
# bashにzshのzsh-autosuggestions / zsh-syntax-highlighting相当の機能を提供する
# ------------------------
install_ble_sh() {
  local ble_dir="$HOME/.local/share/ble.sh"

  if [ -f "$ble_dir/out/ble.sh" ]; then
    echo "✅ ble.sh already installed"
    return
  fi

  if ! command -v gawk &> /dev/null || ! command -v make &> /dev/null; then
    echo "⚠️  gawk または make が見つからないため ble.sh のインストールをスキップしました。"
    return
  fi

  echo "⌨️  Installing ble.sh..."
  git clone --recursive --depth 1 --shallow-submodules \
    https://github.com/akinomyoga/ble.sh.git "$ble_dir" \
    && make -C "$ble_dir" \
    && echo "✅ ble.sh installed"
}

install_ble_sh

# ------------------------
# VSCode extensions
# ------------------------
if command -v code &> /dev/null; then
  # コメント行を除去して拡張機能IDのみを抽出
  grep -v '^//' config/vscode/extensions.txt | sed 's|//.*||' | xargs -n 1 code --install-extension || true
fi
