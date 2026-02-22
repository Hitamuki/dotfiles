# dotfiles

個人的な開発環境の設定ファイル集
macOSとLinuxに対応

## 概要

このリポジトリには以下の設定が含まれる

- シェル設定（Fish shell + Starship）
- ターミナルマルチプレクサ（tmux）
- エディタ設定（Vim）
- Git設定
- パッケージ、アプリケーション管理（Homebrew）
- パッケージバージョン管理（mise）
- VSCode拡張機能

## セットアップ

### クイックスタート

```bash
# リポジトリをクローン

# すべてをセットアップ（macOS）
make mac

# すべてをセットアップ（Linux）
make linux
```

### 個別セットアップ

必要に応じて個別のステップを実行

```bash
# パッケージのインストール
make bootstrap

# 設定ファイルのシンボリックリンク作成
make link

# OS設定の適用
make defaults
```

## 含まれる設定

### シェル環境

- **Fish shell**: モダンで使いやすいシェル
- **Starship**: カスタマイズ可能なプロンプト
- **tmux**: セッション管理とペイン分割
  - マウス操作対応
  - セッションの自動保存・復元（tmux-resurrect/continuum）
  - tmux-powerテーマ適用

### 開発ツール

- **mise**: 複数言語のランタイムバージョン管理ツール
- **Git**: バージョン管理システム
  - ユーザー情報設定
- **Vim**: 軽量エディタ
  - NERDTree（ファイルツリー表示）
  - シンタックスハイライト
  - スマートインデント

## ディレクトリ構成

```
.
├── home/              # ホームディレクトリにリンクされる設定ファイル
│   ├── .config/
│   │   ├── fish/      # Fish shell設定
│   │   ├── mise/      # miseツール設定
│   │   └── starship.toml  # Starshipプロンプト設定
│   ├── .gitconfig     # Git設定
│   ├── .tmux.conf     # tmux設定
│   └── .vimrc         # Vim設定
├── config/            # アプリケーション固有の設定
│   ├── vscode/
│   │   ├── extensions.txt # VSCode拡張機能リスト
│   │   └── settings.json  # VSCode設定
│   └── iterm2/
│       └── themes/
│           └── iceberg.itermcolors  # iTerm2テーマ
├── scripts/
│   ├── bootstrap.sh   # パッケージインストール
│   ├── link.sh        # シンボリックリンク作成
│   └── defaults.sh    # OS設定適用
├── Brewfile           # macOS用パッケージ
├── Brewfile.Linux     # Linux用パッケージ
└── Makefile           # セットアップコマンド
```

## その他

### 備考

- iTerm2テーマ（`config/iterm2/themes/iceberg.itermcolors`）は手動でインポート
- デフォルトシェルは自動的にfishに変更される（`make defaults`実行時）
