# OS別 PATH 設定
case "$(uname)" in
  Darwin)
    export PATH="/opt/homebrew/bin:$PATH"
    ;;
  Linux)
    export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
    ;;
esac

# ble.sh（zsh-autosuggestions / zsh-syntax-highlighting相当）
# ble.sh は .bashrc の先頭で読み込み、末尾で ble-attach する必要がある
if [[ $- == *i* ]] && [ -f "$HOME/.local/share/ble.sh/out/ble.sh" ]; then
  source "$HOME/.local/share/ble.sh/out/ble.sh" --attach=none
fi

# mise の初期化
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
fi

# starship の初期化
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

# ble.sh のアタッチ（.bashrc の一番最後で実行する）
[[ ${BLE_VERSION-} ]] && ble-attach
