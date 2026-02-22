# タスク
.PHONY: all bootstrap link defaults mac linux

# デフォルトターゲット（makeコマンドを引数なしで実行）
all: bootstrap link defaults

bootstrap:
	bash ./scripts/bootstrap.sh

link:
	bash ./scripts/link.sh

defaults:
	bash ./scripts/defaults.sh

mac:
	bash ./scripts/bootstrap.sh mac
	bash ./scripts/link.sh
	bash ./scripts/defaults.sh mac

linux:
	bash ./scripts/bootstrap.sh linux
	bash ./scripts/link.sh
	bash ./scripts/defaults.sh linux
