# dotfiles

- 個人的な開発環境の設定ファイル集
- macOSとLinuxに対応

## 概要

このリポジトリには以下の設定が含まれる

- シェル関連（シェル：Zsh + Sheldon、Fish + Fisher、Starship）
- ターミナルマルチプレクサ（tmux）
- エディタ（VSCode、Vim）
- Git
- パッケージ、アプリケーション管理（Homebrew）
- パッケージバージョン管理（mise）

## セットアップ

### クイックスタート

```bash
# リポジトリをクローン

# 「home/.gitconfig」でGitのユーザー情報設定

# すべてをセットアップ（macOS）
make mac

# すべてをセットアップ（Linux）
make linux

# ターミナルアプリの設定
  # iTerm2のテーマ（`config/iterm2/themes/iceberg.itermcolors`）を手動でインポート
    # iTerm2（Settings → Profiles → Colors → Color Preset
  # ターミナルのフォントを手動で設定
    # iTerm2（Settings → Profiles → Text → Font → 「Nerd Font」で検索
  # 透明度
    # iTerm2（Settings → Profiles → Window → Transparency：30）
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

## ディレクトリ構成

```txt
.
├── home/              # ホームディレクトリにリンクされる設定ファイル
│   ├── .config/
│   │   ├── zsh/           # Zsh設定
│   │   │   └── .zshrc
│   │   ├── sheldon/       # Sheldonプラグインマネージャー設定
│   │   │   └── plugins.toml
│   │   ├── fish/          # Fish設定
│   │   │   ├── config.fish
│   │   │   └── fish_plugins
│   │   ├── mise.toml      # miseツール設定
│   │   └── starship.toml  # Starshipプロンプト設定
│   ├── .gitconfig     # Git設定
│   ├── .tmux.conf     # tmux設定
│   ├── .vimrc         # Vim設定
│   └── .zshenv        # Zsh環境変数（ZDOTDIR設定）
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

- デフォルトのシェルはZsh

### トラブルシューティング
