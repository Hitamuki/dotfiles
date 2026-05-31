# OS別 PATH 設定
case "$(uname)" in
  Darwin)
    export PATH="/opt/homebrew/bin:$PATH"
    ;;
  Linux)
    export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
    ;;
esac

# sheldon でプラグインを読み込む
if command -v sheldon >/dev/null 2>&1; then
  eval "$(sheldon source)"
fi

# mise の初期化
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# starship の初期化
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
