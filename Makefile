# タスク
.PHONY: all bootstrap link defaults mcp herdr-plugins mac linux windows

# デフォルトターゲット（makeコマンドを引数なしで実行）
all: bootstrap link defaults

bootstrap:
	bash ./scripts/bootstrap.sh

link:
	bash ./scripts/link.sh

defaults:
	bash ./scripts/defaults.sh

# MCP サーバー登録。claude CLI のログイン後に手動で実行する
# （初回オンボーディングやログインが前提のため all には含めない）
mcp:
	bash ./scripts/mcp.sh

# herdr プラグインの導入。ビルドスクリプトを実行するプラグインを含むため手動で実行する
herdr-plugins:
	bash ./scripts/herdr-plugins.sh

mac:
	bash ./scripts/bootstrap.sh mac
	bash ./scripts/link.sh
	bash ./scripts/defaults.sh mac

linux:
	bash ./scripts/bootstrap.sh linux
	bash ./scripts/link.sh
	bash ./scripts/defaults.sh linux

# Windows ホストでアプリのみインストール（PowerShell から実行）
# WSL2 側のセットアップは別途 `make linux` を実行する
windows:
	powershell -ExecutionPolicy Bypass -File ./scripts/windows.ps1
