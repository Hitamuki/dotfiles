#!/bin/bash

# ==========================================================
# herdr プラグインの導入
# config/herdr/herdr-plugin.toml を読み込み、herdr plugin install で導入する
#
# 注意:
#   プラグインによっては herdr-plugin.toml の [[build]] でリポジトリ同梱の
#   ビルドスクリプトを実行するため（例: herdr-token-dashboard は Go ビルド）、
#   make all / make mac / make linux には含めず手動実行とする
# ==========================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PLUGIN_FILE="$DOTFILES_DIR/config/herdr/herdr-plugin.toml"

if ! command -v herdr &> /dev/null; then
  echo "❌ herdr が見つかりません。Brewfile 経由でインストールしてください（bootstrap.sh を先に実行してください）。"
  exit 1
fi

if [ ! -f "$PLUGIN_FILE" ]; then
  echo "❌ herdr-plugin.toml が見つかりません: $PLUGIN_FILE"
  exit 1
fi

echo "🔌 Installing herdr plugins..."

grep '^source = ' "$PLUGIN_FILE" | sed -E 's/^source = "(.*)"$/\1/' | while read -r src; do
  echo "herdr plugin install: $src"
  herdr plugin install "$src" --yes
done

echo "✅ Done."
