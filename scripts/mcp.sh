#!/bin/bash

# ==========================================================
# MCP サーバー登録（ユーザースコープ）
# 自動登録されない MCP サーバーを全プロジェクトで使えるよう登録する。
# pencil はインストール時に、Slack / Notion / Google は claude.ai
# コネクタとして自動登録されるため対象外。
# 再実行しても重複しないよう、登録前に同名を削除してから add する。
# ==========================================================

set -e

if ! command -v claude &> /dev/null; then
  echo "⚠️  claude コマンドが見つからないため MCP 登録をスキップします"
  exit 0
fi

echo "🔌 Registering MCP servers (user scope)..."

# stdio 形式（ローカルコマンドで起動）
add_stdio() {
  NAME=$1
  shift
  claude mcp remove -s user "$NAME" > /dev/null 2>&1 || true
  claude mcp add -s user "$NAME" -- "$@"
}

# HTTP 形式（リモート。初回利用時に /mcp で OAuth 認証）
add_http() {
  NAME=$1
  URL=$2
  claude mcp remove -s user "$NAME" > /dev/null 2>&1 || true
  claude mcp add -s user --transport http "$NAME" "$URL"
}

# ------------------------
# stdio
# ------------------------
add_stdio drawio npx -y drawio-mcp-server

# ------------------------
# remote (HTTP) — 初回利用時に /mcp で OAuth 認証
# ------------------------
add_http github   "https://api.githubcopilot.com/mcp/"
add_http context7 "https://mcp.context7.com/mcp"

echo "✅ MCP servers registered."
echo "   HTTP サーバーは Claude Code 内で /mcp を実行して認証してください。"
