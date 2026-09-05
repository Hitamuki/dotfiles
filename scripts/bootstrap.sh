#!/bin/bash

# ==========================================================
# 初期セットアップ
# 開発環境を初期構築するスクリプト
#
# 対応OS:
#   macOS / Linux
# ==========================================================

set -e

# CWD に依存しないよう、スクリプト自身の位置から dotfiles のルートを解決する
DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"

detect_os() {
  case "$(uname -s)" in
    Darwin) echo "mac" ;;
    Linux) echo "linux" ;;
    *) echo "unknown" ;;
  esac
}

# 第1引数（Makefile が渡す mac / linux）があればそれを使い、無ければ自動判定する。
# 実行環境と食い違う指定は誤操作なので中断する。
DETECTED_OS=$(detect_os)
OS="${1:-$DETECTED_OS}"

if [ "$DETECTED_OS" = "unknown" ]; then
  echo "❌ 未対応のOSです（macOS / Linux のみ対応）"
  exit 1
fi

if [ "$OS" != "$DETECTED_OS" ]; then
  echo "❌ 指定されたOS（${OS}）が実行環境（${DETECTED_OS}）と一致しません。"
  exit 1
fi

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
    brew bundle --file="$DOTFILES_DIR/Brewfile"
  elif [ "$OS" = "linux" ]; then
    brew bundle --file="$DOTFILES_DIR/Brewfile.Linux"
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
  grep -v '^//' "$DOTFILES_DIR/config/vscode/extensions.txt" | sed 's|//.*||' | xargs -n 1 code --install-extension || true
fi

# ------------------------
# Chrome extensions
# Chromeは拡張機能をサイレントインストールできないため、
# config/chrome/extensions.json に列挙したWeb Storeページを開く
# （各ページで「Chromeに追加」を手動でクリックする）
# ------------------------
CHROME_FOUND=1
if [ "$OS" = "mac" ] && [ -d "/Applications/Google Chrome.app" ]; then
  open_chrome_url() { open -a "Google Chrome" "$1"; }
elif command -v google-chrome &> /dev/null; then
  open_chrome_url() { google-chrome "$1" &> /dev/null & }
elif command -v google-chrome-stable &> /dev/null; then
  open_chrome_url() { google-chrome-stable "$1" &> /dev/null & }
else
  CHROME_FOUND=0
fi

if [ "$CHROME_FOUND" = "1" ] && [ -f "$DOTFILES_DIR/config/chrome/extensions.json" ]; then
  echo "🧩 Opening Chrome Web Store pages..."
  grep '"url":' "$DOTFILES_DIR/config/chrome/extensions.json" | sed -E 's/^[[:space:]]*"url": *"(.*)",?$/\1/' | while read -r url; do
    open_chrome_url "$url"
  done
  echo "✅ 各タブで「Chromeに追加」をクリックしてインストールしてください。"
else
  echo "⚠️  Google Chromeが見つからないため拡張機能ページのオープンをスキップしました。"
fi
