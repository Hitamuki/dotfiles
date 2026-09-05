# dotfiles

- 個人的な開発環境の設定ファイル集
- macOS / Linux / Windows（WSL2）に対応

## 概要

このリポジトリには以下の設定が含まれる

- シェル関連（シェル：Zsh + Sheldon、Fish + Fisher、Starship。bashは手動起動時のみble.shで補助）
- ターミナルマルチプレクサ（tmux）
- エディタ（VSCode、Vim）
- Git
- パッケージ、アプリケーション管理（Homebrew / Windows のアプリは winget）
- パッケージバージョン管理（mise）
- Claude Code（設定 + ステータスライン + MCPサーバー登録）

## セットアップ

OSごとに手順が異なるため、該当する環境のセクションを参照する。

### macOS

```bash
# リポジトリをクローン

# すべてをセットアップ
make mac

# Claude Code にログイン後、MCPサーバーを登録
#   claude にログイン → make mcp → Claude Code 内で /mcp を実行し認証
make mcp

# herdrのClaude Codeインテグレーションを導入
herdr integration install claude

# herdrプラグインの導入（config/herdr/herdr-plugin.toml で管理。ビルドスクリプトを実行するため内容確認の上で実行）
make herdr-plugins

# ターミナルアプリの設定
  # iTerm2のテーマ（`config/iterm2/themes/iceberg.itermcolors`）を手動でインポート
    # iTerm2（Settings → Profiles → Colors → Color Preset
  # ターミナルのフォントを手動で設定
    # iTerm2（Settings → Profiles → Text → Font → 「Nerd Font」で検索
  # 透明度
    # iTerm2（Settings → Profiles → Window → Transparency：30）
```

### Linux

素のディストリビューションには `git` / `make` / `curl` などが入っておらず、
リポジトリのクローンや `make linux` の時点で失敗するため、先に前提パッケージを入れる。

```bash
# 前提パッケージ（Debian / Ubuntu 系）
#   build-essential procps curl file git : Homebrew on Linux の要求パッケージ
#   unzip fontconfig                     : Nerd Font の展開・登録に使用
sudo apt update && sudo apt install -y build-essential procps curl file git unzip fontconfig
```

```bash
# リポジトリをクローン

# すべてをセットアップ
make linux

# Gitのユーザー情報を設定
#   make linux（link.sh）が ~/.gitconfig.local の雛形を生成するので、そこに記入する
#   ※ home/.gitconfig はリポジトリ管理下なので個人情報を書かない
vim ~/.gitconfig.local

# Claude Code にログイン後、MCPサーバーを登録
#   claude にログイン → make mcp → Claude Code 内で /mcp を実行し認証
make mcp

# herdrのClaude Codeインテグレーションを導入
herdr integration install claude

# herdrプラグインの導入（config/herdr/herdr-plugin.toml で管理。ビルドスクリプトを実行するため内容確認の上で実行）
make herdr-plugins
```

### Windows（Windows + WSL2）

Windows では2つの環境を順番にセットアップする。
`make windows` は **Windows ホスト側の GUI アプリをインストールするだけ** で、開発環境は構築されない。
開発環境は WSL2 上の `make linux` で構築するため、**両方の実行が必要**。

1. **Windows ホスト（PowerShell）── アプリのインストールのみ**

   - **リポジトリをクローン**（以降の手順はこのREADMEを参照しながら進める）

   - **WSL2 と Ubuntu のインストール**（未導入の場合）

     ```powershell
     # 管理者権限の PowerShell で実行
     wsl --install
     ```

     - 既定のディストリビューションとして Ubuntu が導入される（別のディストリビューションを使う場合は `wsl --install -d <ディストリ名>`）。
     - 実行後、再起動を求められることがある。再起動後、初回起動時に Ubuntu の初期化とUNIXユーザー名・パスワードの設定を行う。
     - 既に `wsl --install` を実行済みで OS が古い場合は `wsl --update` でカーネルを更新できる。

   - **アプリのインストール**

     ```powershell
     # Brewfile の cask 相当（VSCode・Chrome・Slack など）を winget で導入
     make windows
     ```

     - インストール対象は `Wingetfile` で管理する。
     - `make` が無い場合は直接実行も可: `powershell -ExecutionPolicy Bypass -File ./scripts/windows.ps1`
     - winget が無い場合は Microsoft Store から「App Installer」を導入する。

2. **WSL2（必須）── 開発環境のセットアップ**

   WSL2はWindowsホストとは別のファイルシステムのため、リポジトリを別途クローンする。

   素の WSL2 Ubuntu には `git` / `make` / `unzip` が入っていないため、
   **前提パッケージのインストールが最初のステップになる**（これを省くとクローンと `make linux` の時点で失敗する）。

   ```bash
   # 前提パッケージ（Homebrew on Linux の要求パッケージ + unzip）
   #   フォントは Windows ホスト側が担当するため fontconfig は不要
   sudo apt update && sudo apt install -y build-essential procps curl file git unzip
   ```

   ```bash
   # リポジトリをクローン

   # CLI ツール・dotfiles・OS設定（Linux と同じ）
   make linux

   # Gitのユーザー情報を設定
   #   make linux（link.sh）が ~/.gitconfig.local の雛形を生成するので、そこに記入する
   #   ※ home/.gitconfig はリポジトリ管理下なので個人情報を書かない
   vim ~/.gitconfig.local
   ```

   > `make windows` だけでは開発環境は構築されない。
   > 必ず WSL2 側で `make linux` を実行すること。

   > **VSCode設定のリンクは `make link` の再実行が必要**
   > VSCode のリモート用ディレクトリ `~/.vscode-server` は、**VSCode から初めて WSL に接続した後**にしか作られない。
   > そのため初回セットアップでは必ずローカル Linux 用のパス（`~/.config/Code/User/settings.json`）にリンクされる。
   > VSCode で一度 WSL に接続してから `make link` を再実行すると、正しい `~/.vscode-server/data/Machine/settings.json` にリンクされる
   > （`link.sh` は WSL2 上でこの状態を検出すると警告を表示する）。

### インストール後の確認（mise）

`make` 実行時に mise のツールインストールに失敗することがある。
セットアップ後に `mise list` でインストール状況を確認し、未インストールのツールがあれば `mise install` を実行する。

```bash
# インストール済みツールの確認
mise list

# 未インストールのツールがあればインストール
mise install
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

# MCPサーバーの登録（claude CLI のログイン後に実行）
make mcp

# herdrのClaude Codeインテグレーションを導入
herdr integration install claude

# herdrプラグインの導入
make herdr-plugins
```

> **Note**
> `make mcp` は Claude Code にログイン済みであることが前提のため、`make all` / `make mac` / `make linux` には含めず、手動で実行する。
> 自動登録されない MCP サーバー（drawio / github / context7）をユーザースコープで登録する。pencil や Slack・Notion・Google は自動登録（pencil はインストール時、それ以外は claude.ai コネクタ）されるため対象外。
> 登録後、Claude Code 内で `/mcp` を実行して各 HTTP サーバーを認証する。
>
> `herdr integration install claude` はherdrが `~/.claude/hooks/herdr-agent-state.sh`（herdrが管理・自動生成するランタイムファイルのため dotfiles では追跡しない）を生成し、`home/.claude/settings.json` に `SessionStart` フックを追記するコマンド。マシンごとに手動実行が必要（`make all` / `make mac` / `make linux` には含めない）。
> フックの実行コマンドは `bash "$HOME/.claude/hooks/herdr-agent-state.sh" session` のように `$HOME` で参照しているため、`home/.claude/settings.json` はどの環境でもそのまま利用できる。
>
> `make herdr-plugins`（`scripts/herdr-plugins.sh`）は `config/herdr/herdr-plugin.toml` に列挙したプラグインを `herdr plugin install` で導入する。プラグインによってはリポジトリ同梱のビルドスクリプトを実行する（例: herdr-token-dashboardはGoビルドを実行するため、Brewfileに `brew "go"` を追加済み）ため、`make all` / `make mac` / `make linux` には含めず、内容を確認した上で手動実行する。

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
│   │   ├── bash/           # bash設定
│   │   │   └── .bashrc     # ble.shの読み込みなど
│   │   ├── mise.toml      # miseツール設定
│   │   ├── starship.toml  # Starshipプロンプト設定
│   │   ├── alacritty/     # Alacritty設定
│   │   │   └── alacritty.toml
│   │   └── herdr/         # herdr設定
│   │       └── config.toml
│   ├── .claude/
│   │   ├── settings.json  # Claude Code設定
│   │   └── statusline.sh  # Claude Codeのステータスライン（settings.jsonのstatusLineから呼ばれる）
│   ├── .gitconfig     # Git共通設定（個人情報は書かず ~/.gitconfig.local をincludeする）
│   ├── .tmux.conf     # tmux設定
│   ├── .vimrc         # Vim設定
│   ├── .zshenv        # Zsh環境変数（ZDOTDIR設定）
│   └── .bashrc        # bash設定を読み込むshim（本体は.config/bash/.bashrc）
├── config/            # アプリケーション固有の設定
│   ├── vscode/
│   │   ├── extensions.txt # VSCode拡張機能リスト
│   │   └── settings.json  # VSCode設定
│   ├── iterm2/
│   │   └── themes/
│   │       └── iceberg.itermcolors  # iTerm2テーマ
│   ├── herdr/
│   │   └── herdr-plugin.toml  # herdrプラグイン一覧（herdr plugin installで導入）
│   └── chrome/
│       └── extensions.json   # Chrome拡張機能一覧（bootstrap.shがWeb Storeページを開く）
├── scripts/
│   ├── bootstrap.sh     # パッケージインストール・Chrome拡張機能ページオープン等
│   ├── link.sh          # シンボリックリンク作成
│   ├── defaults.sh      # OS設定適用
│   ├── mcp.sh           # MCPサーバー登録（claudeログイン後に手動実行）
│   ├── herdr-plugins.sh # herdrプラグイン導入（手動実行）
│   └── windows.ps1      # Windowsアプリインストール（winget）
├── Brewfile           # macOS用パッケージ
├── Brewfile.Linux     # Linux用パッケージ
├── Wingetfile         # Windows用アプリ（winget）
└── Makefile           # セットアップコマンド
```

## その他

### 備考

- デフォルトのシェルはZsh
- bashにもプラグインマネージャー相当の仕組みとして [ble.sh](https://github.com/akinomyoga/ble.sh) を導入している（`bootstrap.sh` が自動でclone・ビルドする）
  - zshの `zsh-autosuggestions` + `zsh-syntax-highlighting` に相当する自動候補表示・シンタックスハイライトをbashでも利用できる
  - zshで使っているSheldonはビルド済みファイルの存在を前提にプラグインを解決するため、ビルドが必要なble.shの管理には向かない。そのためble.shだけは `bootstrap.sh` 内で個別にclone・ビルドしている
  - デフォルトシェルはbashに変更しない。手動で `bash` を起動した場合にのみ有効
- Gitの設定は「共通設定」と「マシン・個人ごとの設定」の2ファイルに分かれている
  - `home/.gitconfig`（= `~/.gitconfig`。リポジトリ管理下）：全環境で共通の設定。末尾で `~/.gitconfig.local` を include する
  - `~/.gitconfig.local`（リポジトリ管理外）：`user.name` / `user.email`、認証ヘルパー、署名鍵などマシンごとに変わる設定
  - 個人情報をリポジトリ管理下のファイルに書くと、全員のローカルリポジトリが常に dirty になるため分離している
  - `~/.gitconfig.local` の雛形は `link.sh` が生成する（既存の場合は上書きしない）
  - include は共通設定の**末尾**に置いているため、`~/.gitconfig.local` 側で共通設定を上書きできる
  - 共通設定には新しめのGitを前提とする項目（`push.autoSetupRemote` / `merge.conflictstyle = zdiff3` / `rebase.updateRefs` など）を含む。必要バージョンは `home/.gitconfig` のコメントに記載しており、古いGitでは該当項目が無視されるだけで他には影響しない
- フォントは用途ごとに2種類を使い分ける。OSごとに導入経路が異なるため、追加・変更時は下記を揃える
  - **FiraCode Nerd Font**：ターミナル用（Alacritty / VSCodeの統合ターミナル）。Nerd Fontの記号を表示するために必要
    - macOS：`Brewfile` の `cask "font-fira-code-nerd-font"`
    - Linux：`scripts/defaults.sh`（Homebrewのcaskがフォントに非対応なため nerd-fonts のリリースを直接ダウンロードする）
    - Windows：`scripts/windows.ps1`（wingetに FiraCode Nerd Font のパッケージが無いため直接ダウンロードする）
  - **Ricty Diminished**：VSCodeのエディターフォント用（`Brewfile` の `cask "font-ricty-diminished"`）
  - WSL2 では画面を描画するのが Windows ホスト側のターミナルなので、Linux側のフォントインストールは `defaults.sh` が自動でスキップする
  - 参照側の設定は `home/.config/alacritty/alacritty.toml` と `config/vscode/settings.json`（`editor.fontFamily` / `terminal.integrated.fontFamily`）
- Claude Codeのステータスラインは `home/.claude/statusline.sh` が描画する（`home/.claude/settings.json` の `statusLine` から呼ばれる）
  - 日本語のキーと値で最大4行を表示する
    1. モデル・思考量・拡張思考・高速モード・出力スタイル
    2. ディレクトリ・ブランチ・変更行数・経過時間
    3. コンテキスト（使用率と 使用量/上限）・入力トークン・出力トークン・コスト
    4. レート上限（5時間・7日間の使用率とリセット時刻）
  - 4行目はレート上限を取得できるプラン（Claude.ai Pro / Max）で、最初のAPI応答があった後にのみ表示される。思考量・拡張思考・高速モードも値が渡ってこない環境では自動的に省略される
  - 使用率は70%以上で黄、90%以上で赤に色が変わる
  - 標準入力のJSONの解析に `jq` を使うため、`Brewfile` / `Brewfile.Linux` に `brew "jq"` を含めている

### トラブルシューティング

#### `make mac` 実行中に `mise: command not found` で失敗する

- **原因**：Homebrew を新規インストールした直後は、同じシェル内では `PATH` に `/opt/homebrew/bin` が反映されていない。そのため `bootstrap.sh` 内の `brew bundle`（`mise` のインストール）が実行されず、後続の `link.sh` が `mise install` に失敗していた。
- **対処**：本リポジトリの `scripts/bootstrap.sh` / `scripts/link.sh` は既に対策済み（インストール直後に `eval "$(brew shellenv)"` でPATHを通すよう修正済み）。それでも発生する場合は以下を試す。

  ```bash
  # Homebrew を手動でPATHに通してから再実行
  eval "$(/opt/homebrew/bin/brew shellenv)"
  make mac
  ```

#### Homebrew インストール直後に `brew: command not found` になる

- **原因**：Homebrewのインストーラーは `~/.zprofile` にPATH設定を追記するが、それは**新しいシェルを起動したときにだけ**反映される。インストール直後の同じターミナルには反映されない。
- **対処**：ターミナルを再起動するか、以下を実行してから続きのコマンドを実行する。

  ```bash
  eval "$(/opt/homebrew/bin/brew shellenv)"
  ```

#### `make mac` 実行中に `sudo` パスワードを複数回聞かれる

- **原因**：`bootstrap.sh` はHomebrewが `PATH` 上で見つからない場合、インストール済みかどうかに関わらず再度インストーラーを起動する（Homebrew自体は既にインストール済みなら安全にスキップされるが、その前段の `sudo -v` は毎回実行される）。
- **対処**：動作上問題はないため、パスワードを再入力すればそのまま進行する。気になる場合は事前に `eval "$(/opt/homebrew/bin/brew shellenv)"` を実行してからセットアップする。

#### `mise install` で特定のツールのビルドに失敗する（想定）

- **原因**：`node` などソースビルドが発生するツールは、Xcode Command Line Tools やビルド依存ライブラリが無いと失敗することがある。
- **対処**：

  ```bash
  xcode-select --install

  # 失敗したツールだけ詳細ログを見ながら再実行
  mise install <tool>@<version> --verbose
  ```

#### `make link` で既存の設定ファイルが消える

- **原因**：`link.sh` の `link()` は**退避せずに** `rm -rf` してからシンボリックリンクを貼る（mise等が実ファイルを生成してリンクを上書きするケースでも常にリポジトリを正とするため）。リンク対象と同じパスに手元だけの設定があると失われる。
- **対処**：`make link` を実行する前に、リンク対象（`README` の「ディレクトリ構成」の `home/` 配下）と同じパスに手元固有の設定が無いか確認する。Gitのユーザー情報のようなマシン固有の設定は、リンク対象外の `~/.gitconfig.local` に置く。

#### VSCode拡張機能がインストールされない

- **原因**：`bootstrap.sh` は `code` コマンドが `PATH` に存在する場合のみ拡張機能をインストールする。VSCodeを個別インストールした直後は `code` コマンドが未登録なことが多い。
- **対処**：VSCode内でコマンドパレット（`Cmd+Shift+P`）から `Shell Command: Install 'code' command in PATH` を実行し、`make bootstrap` を再実行する。

#### Chrome拡張機能のページが開かない・スキップされる

- **原因**：`bootstrap.sh` は Google Chrome（macOSは `/Applications/Google Chrome.app`、Linuxは `google-chrome` / `google-chrome-stable` コマンド）が見つかる場合のみ `config/chrome/extensions.json` のWeb Storeページを開く。Brewfileのcask導入直後でインストールが完了していないと検出に失敗することがある。
- **対処**：Chromeのインストール完了を確認してから `make bootstrap` を再実行する。Chromeは拡張機能をサイレントインストールできないため、開いた各タブで「Chromeに追加」を手動でクリックする必要がある。

#### WSL2 でターミナルのアイコン（Nerd Font の記号）が豆腐になる

- **原因**：WSL2 の画面を描画するのは Windows ホスト側のターミナル（Windows Terminal など）なので、Linux側にフォントを入れても表示には反映されない（`defaults.sh` はWSL2を検出してLinux側のインストールをスキップする）。
- **対処**：Windows ホスト側で `make windows` を実行して FiraCode Nerd Font を導入し、ターミナルのフォント設定で `FiraCode Nerd Font` を選ぶ。

#### Linux（WSL2含む）でシェルを `zsh` に変更したのに反映されない

- **原因**：`defaults.sh` の `chsh -s` はログインシェルの設定を変更するだけで、既に開いているターミナルセッションには反映されない。
- **対処**：ターミナル（WSL2の場合はWindows Terminalなど）を再起動する。
