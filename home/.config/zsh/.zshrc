# OS別 PATH 設定
case "$(uname)" in
  Darwin)
    export PATH="/opt/homebrew/bin:$PATH"
    ;;
  Linux)
    export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
    ;;
esac

# ユーザーローカルの実行ファイル (~/.local/bin) を PATH に追加
export PATH="$HOME/.local/bin:$PATH"

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

if [[ -f "${ZDOTDIR:-$HOME}/.zshrc.local" ]]; then
  source "${ZDOTDIR:-$HOME}/.zshrc.local"
fi
