#!/bin/bash

# ========================================================
# OS設定の変更
# OSレベルの設定（UI・キーボード・Finder・Desktopなど）を適用する
# ========================================================

set -e

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

# WSL2 判定（WSL特有の分岐に使用する）
if [ "$OS" = "linux" ] && grep -qi microsoft /proc/version 2>/dev/null; then
  IS_WSL=1
else
  IS_WSL=0
fi

# --------------------
# Setup brew PATH
# --------------------
# bootstrap.sh / link.sh とは別プロセスで実行されるためPATHが引き継がれない。
# Linux では zsh も Homebrew 経由で入るため、これが無いと後続のシェル判定に失敗する。
if [ -x "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/usr/local/bin/brew" ]; then
  eval "$(/usr/local/bin/brew shellenv)"
elif [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -x "$HOME/.linuxbrew/bin/brew" ]; then
  eval "$($HOME/.linuxbrew/bin/brew shellenv)"
fi

echo "⚙️ Applying defaults for $OS"

# --------------------
# Zsh shell setup (Linux only)
# --------------------
if [ "$OS" = "linux" ] && command -v zsh &> /dev/null; then
  ZSH_PATH=$(command -v zsh)

  # /etc/shellsにzshが登録されているか確認
  if ! grep -q "$ZSH_PATH" /etc/shells 2>/dev/null; then
    echo "Adding zsh to /etc/shells..."
    echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
  fi

  # 現在のシェルがzshでない場合は変更
  if [ "$SHELL" != "$ZSH_PATH" ]; then
    echo "Changing default shell to zsh..."
    chsh -s "$ZSH_PATH"
    echo "✅ Default shell changed to zsh. Please restart your terminal."
  else
    echo "✅ Zsh is already the default shell"
  fi
fi

# --------------------
# macOS defaults
# --------------------
if [ "$OS" = "mac" ]; then
  # Finder: 隠しファイル表示
  defaults write com.apple.finder AppleShowAllFiles -bool true

  # キーリピート
  defaults write NSGlobalDomain KeyRepeat -int 20
  defaults write NSGlobalDomain InitialKeyRepeat -int 10

  # Nerd Font（Fira Code）は Brewfile の cask "font-fira-code-nerd-font" で導入する

  # Finder 再起動
  killall Finder || true
fi

# --------------------
# Linux defaults
# --------------------
if [ "$OS" = "linux" ]; then
  # GNOME: 日付表示
  gsettings set org.gnome.desktop.interface clock-show-date true || true

  # --------------------
  # Nerd Font (Fira Code)
  # --------------------
  # Homebrew の cask はLinuxのフォントに対応しないため、ここだけ直接ダウンロードする
  # （macOS は Brewfile の cask、Windows は scripts/windows.ps1 が担当）
  install_nerd_font_linux() {
    # WSL2 の画面を描画するのは Windows ホスト側のターミナルなので、
    # Linux 側にフォントを入れても表示には反映されない
    if [ "$IS_WSL" = "1" ]; then
      echo "⏭️  WSL2 のためLinux側のフォントインストールをスキップしました。"
      echo "   フォントは Windows ホスト側で 'make windows' を実行して導入してください。"
      return
    fi

    # 素のディストリビューションでは fontconfig / unzip が未インストールのことがある。
    # set -e で途中失敗しないよう、コマンドの有無を先に確認してスキップする
    for cmd in fc-list fc-cache curl unzip; do
      if ! command -v "$cmd" &> /dev/null; then
        echo "⚠️  $cmd が見つからないためFira Code Nerd Fontのインストールをスキップしました。"
        echo "   'sudo apt install -y fontconfig curl unzip' の後に 'make defaults' を再実行してください。"
        return
      fi
    done

    if fc-list | grep -q "FiraCode Nerd Font"; then
      echo "✅ Fira Code Nerd Font already installed"
      return
    fi

    echo "🔤 Installing Fira Code Nerd Font..."
    mkdir -p ~/.fonts
    curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip -o /tmp/FiraCode.zip
    unzip -o /tmp/FiraCode.zip -d ~/.fonts
    fc-cache -f
    rm /tmp/FiraCode.zip
    echo "✅ Fira Code Nerd Font installed"
  }

  install_nerd_font_linux
fi
