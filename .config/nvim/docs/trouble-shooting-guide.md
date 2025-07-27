# Neovim lazy.nvim トラブルシューティングガイド

## よくあるエラーと解決方法

### 1. `module 'cmp_nvim_lsp' not found` エラー

**原因**: プラグインの依存関係と読み込み順序の問題

**解決方法**:

```vim
" 1. lazy.nvimを開く
:Lazy

" 2. 全プラグインを再同期
:Lazy sync

" 3. Neovimを再起動
:q
nvim
```

**詳細説明**: LSP プラグインが補完プラグインより先に読み込まれると発生します。修正版では適切な依存関係を設定済みです。

### 2. `attempt to call field 'setup_handlers' (a nil value)` エラー

**原因**: mason-lspconfig が正しく読み込まれていない

**解決方法**:

```vim
" 1. Masonを手動でインストール
:Lazy install mason.nvim

" 2. mason-lspconfigを手動でインストール
:Lazy install mason-lspconfig.nvim

" 3. 全体を再同期
:Lazy sync

" 4. 再起動
:q
nvim
```

**確認方法**:

```vim
" プラグインの状態確認
:Lazy
```

### 3. LSP サーバーが起動しない

**確認手順**:

```vim
" LSPの状態を確認
:LspInfo

" Masonの状態を確認
:Mason

" 診断情報を確認
:checkhealth
```

**解決方法**:

1. 必要な LSP サーバーがインストールされているか確認
2. `:Mason`でサーバーを手動インストール
3. ファイルタイプが正しく認識されているか確認

### 3. Telescope が動作しない

**確認項目**:

- `ripgrep`がインストールされているか
- `fd`がインストールされているか（オプション）

**インストール方法**:

```bash
# macOS
brew install ripgrep fd

# Ubuntu/Debian
sudo apt install ripgrep fd-find

# Arch Linux
sudo pacman -S ripgrep fd
```

### 4. Treesitter パーサーのエラー

**解決方法**:

```vim
" パーサーを手動でインストール
:TSInstall lua javascript typescript python

" パーサーを更新
:TSUpdate

" 状態を確認
:TSModuleInfo
```

### 5. プラグインが読み込まれない

**デバッグ手順**:

```vim
" lazy.nvimの状態を確認
:Lazy

" プラグインを手動で読み込み
:Lazy load [plugin-name]

" ログを確認
:Lazy log
```

### 6. 設定ファイルの構文エラー

**チェック方法**:

```vim
" Lua構文をチェック
:luafile %

" 設定を再読み込み
:source $MYVIMRC
```

**よくある間違い**:

- 括弧の不一致: `{`, `}`, `(`, `)`, `[`, `]`
- カンマの不足: テーブル要素間
- 文字列の引用符: `"` と `'` の使い分け

### 7. パフォーマンスの問題

**診断コマンド**:

```vim
" 起動時間を測定
nvim --startuptime startup.log

" プロファイリング開始
:profile start profile.log
:profile func *
:profile file *

" プロファイリング終了
:profile pause
:noautocmd qall!
```

**改善方法**:

- 不要なプラグインを無効化
- 遅延読み込み設定を追加
- `init.lua`の設定を最適化

### 8. カラースキームが適用されない

**確認手順**:

```vim
" 利用可能なカラースキーム確認
:colorscheme <Tab>

" 手動で適用
:colorscheme catppuccin

" ターミナルの色サポート確認
:set termguicolors?
```

### 9. キーマップが動作しない

**デバッグ方法**:

```vim
" キーマップ一覧を確認
:map
:nmap
:imap
:vmap

" 特定のキーマップを確認
:map <leader>ff

" which-keyでヘルプ表示
" <leader>キーを押して待機
```

### 10. Git 統合が動作しない

**確認項目**:

- Git リポジトリ内で作業しているか
- `.git`ディレクトリが存在するか
- Git が正しくインストールされているか

```bash
# Git状態確認
git status
git --version
```

## 予防策

### 1. 定期的なメンテナンス

```vim
" 週1回実行
:Lazy sync
:checkhealth
:TSUpdate
```

### 2. バックアップの作成

```bash
# 設定をバックアップ
cp -r ~/.config/nvim ~/.config/nvim.backup
```

### 3. 段階的な設定変更

- 一度に多くの変更をしない
- 変更後は必ずテストする
- 問題があれば即座にロールバック

### 4. ログの確認習慣

```vim
:messages  " メッセージ履歴
:Lazy log  " プラグインログ
```

## 緊急時の復旧方法

### 完全リセット

```bash
# 1. 設定をバックアップ
mv ~/.config/nvim ~/.config/nvim.broken

# 2. 最小構成で再作成
mkdir -p ~/.config/nvim
echo 'print("Neovim is working")' > ~/.config/nvim/init.lua

# 3. Neovimが起動することを確認
nvim

# 4. 段階的に設定を復元
```

### セーフモード起動

```bash
# プラグインを読み込まずに起動
nvim --noplugin

# 最小限の設定で起動
nvim -u NONE
```

このガイドを参考に、問題を段階的に特定・解決してください。
