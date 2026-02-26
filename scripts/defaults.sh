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
  esac
}

OS=$(detect_os)

echo "⚙️ Applying defaults for $OS"

# --------------------
# Fish shell setup
# --------------------
if command -v fish &> /dev/null; then
  FISH_PATH=$(command -v fish)
  
  # /etc/shellsにfishが登録されているか確認
  if ! grep -q "$FISH_PATH" /etc/shells 2>/dev/null; then
    echo "🐟 Adding fish to /etc/shells..."
    echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
  fi
  
  # 現在のシェルがfishでない場合は変更
  if [ "$SHELL" != "$FISH_PATH" ]; then
    echo "🐟 Changing default shell to fish..."
    chsh -s "$FISH_PATH"
    echo "✅ Default shell changed to fish. Please restart your terminal."
  else
    echo "✅ Fish is already the default shell"
  fi
fi

# --------------------
# macOS defaults
# --------------------
if [ "$OS" = "mac" ]; then
  # Finder: 隠しファイル表示
  defaults write com.apple.finder AppleShowAllFiles -bool true

  # キーリピート高速化
  defaults write NSGlobalDomain KeyRepeat -int 1
  defaults write NSGlobalDomain InitialKeyRepeat -int 10

  # Nerd Fontインストール (Fira Code)
  if ! brew list | grep -q "font-fira-code-nerd-font"; then
    echo "🔤 Installing Fira Code Nerd Font..."
    brew install font-fira-code-nerd-font
    echo "✅ Fira Code Nerd Font installed"
  else
    echo "✅ Fira Code Nerd Font already installed"
  fi

  # Finder 再起動
  killall Finder || true
fi

# --------------------
# Linux defaults
# --------------------
if [ "$OS" = "linux" ]; then
  # GNOME: 日付表示
  gsettings set org.gnome.desktop.interface clock-show-date true || true

  # Nerd Fontインストール (Fira Code)
  if ! fc-list | grep -q "FiraCode Nerd Font"; then
    echo "🔤 Installing Fira Code Nerd Font..."
    mkdir -p ~/.fonts
    curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip -o /tmp/FiraCode.zip
    unzip /tmp/FiraCode.zip -d ~/.fonts
    fc-cache -fv
    rm /tmp/FiraCode.zip
    echo "✅ Fira Code Nerd Font installed"
  else
    echo "✅ Fira Code Nerd Font already installed"
  fi
fi

