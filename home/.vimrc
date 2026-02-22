" ========== プラグイン設定（vim-plug使用） ==========
" Ctrl + t で NERDTree をトグル表示
nnoremap <C-t> :NERDTreeToggle<CR>

" プラグイン定義開始
call plug#begin()
  Plug 'preservim/nerdtree'  " ファイルツリー表示プラグイン
call plug#end()

" ========== 基本動作の設定 ==========
" クリップボードをOSと共有
set clipboard=unnamed

" ファイルの文字コードを UTF-8 に設定
set fenc=utf-8

" バックアップファイルを作成しない
set nobackup

" スワップファイルを作成しない
set noswapfile

" 外部で変更されたファイルは自動で読み直す
set autoread

" 未保存でもバッファ切り替え可能にする
set hidden

" 入力中のコマンドをステータスに表示
set showcmd

" ========== 見た目・表示系 ==========
" 行番号を表示
set number

" 現在の行と列をハイライト
set cursorline
" set cursorcolumn

" 行末のさらに右にもカーソルを移動できる
set virtualedit=onemore

" 括弧入力時に対応する括弧を表示
set showmatch

" スマートインデント（構文ベースで自動インデント）
set smartindent

" ビープ音を画面フラッシュで代用
set visualbell

" ステータスラインを常に表示
set laststatus=2

" コマンド補完時に一覧表示＆最長一致まで補完
set wildmode=list:longest

" 折り返し行での移動を自然に（見た目通り）
nnoremap j gj
nnoremap k gk

" シンタックスハイライトを有効にする
syntax enable

" ========== インデント・タブ系 ==========
" タブなどの不可視文字を表示
set list listchars=tab:\▸\-

" タブ入力をスペースに変換
set expandtab

" タブの表示幅を2スペースに設定
set tabstop=2

" 自動インデントの幅も2スペースに設定
set shiftwidth=2

" ========== 検索の設定 ==========
" 小文字だけの検索は大文字小文字を区別しない
set ignorecase

" 大文字を含む検索語は大文字小文字を区別
set smartcase

" 検索中にマッチをリアルタイム表示
set incsearch

" 検索が末尾に達したら先頭から再検索
set wrapscan

" 検索語にマッチした箇所をハイライト
set hlsearch

" ESCを2回押すとハイライト解除
nmap <Esc><Esc> :nohlsearch<CR><Esc>

