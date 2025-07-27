# Neovim lazy.nvim セットアップガイド

このガイドでは、lazy.nvim を使用した最低限実用的な Neovim 環境の構築方法を説明します。

## ディレクトリ構成

```txt
~/.config/nvim/
├── init.lua                 # メイン設定ファイル
├── lua/
│   ├── config/
│   │   └── lazy.lua         # lazy.nvim設定
│   └── plugins/
│       ├── colorscheme.lua  # カラースキーム
│       ├── treesitter.lua   # シンタックスハイライト
│       ├── telescope.lua    # ファジーファインダー
│       ├── lsp.lua          # LSP設定
│       ├── completion.lua   # 自動補完
│       ├── utils.lua        # ユーティリティプラグイン
│       └── editor.lua       # エディタ機能強化
```

## インストール済みプラグイン

### 🎨 カラースキーム

- **catppuccin/nvim**: 美しいカラースキーム（Mocha テーマ）

### 🌳 シンタックスハイライト

- **nvim-treesitter**: モダンなシンタックスハイライト
- 自動インストール対応言語: Lua, JavaScript, TypeScript, Python, Rust, Go, C/C++など

### 🔍 ファジーファインダー

- **telescope.nvim**: 高性能ファイル・文字列検索
- **telescope-fzf-native**: ネイティブ fzf 統合

### 🧠 LSP（Language Server Protocol）

- **nvim-lspconfig**: LSP 設定
- **mason.nvim**: LSP サーバー自動インストール
- **mason-lspconfig**: mason 統合
- **neodev.nvim**: Lua 開発サポート

### ✨ 自動補完

- **nvim-cmp**: 自動補完エンジン
- **LuaSnip**: スニペットエンジン
- **friendly-snippets**: 事前定義スニペット

### 🛠️ ユーティリティ

- **nvim-tree**: ファイルエクスプローラー
- **lualine**: ステータスライン
- **gitsigns**: Git 統合
- **Comment.nvim**: コメントアウト
- **nvim-autopairs**: 自動ペア
- **indent-blankline**: インデントガイド
- **bufferline**: バッファライン

### 📝 エディタ機能強化

- **alpha-nvim**: スタート画面
- **flash.nvim**: 高速移動
- **nvim-spectre**: 検索・置換
- **which-key**: キーバインドヘルプ
- **nvim-notify**: 通知システム
- **todo-comments**: TODO コメントハイライト
- **trouble.nvim**: 診断表示
- **toggleterm**: ターミナル統合
- **persistence.nvim**: セッション管理
- **nvim-lastplace**: カーソル位置記憶
- **vim-illuminate**: 単語ハイライト

## 主要キーバインド

### 基本操作

- `<Space>`: リーダーキー
- `<Esc>`: 検索ハイライト消去
- `<C-h/j/k/l>`: ウィンドウ間移動

### ファイル操作

- `<leader>e`: ファイルツリー切り替え
- `<leader>ff`: ファイル検索
- `<leader>fg`: 文字列検索
- `<leader>fb`: バッファ検索
- `<leader>fr`: 最近のファイル

### LSP 機能

- `gd`: 定義へジャンプ
- `gr`: 参照表示
- `K`: ホバー情報
- `<leader>rn`: リネーム
- `<leader>ca`: コードアクション
- `<leader>f`: フォーマット

### Git 操作

- `]c` / `[c`: 変更箇所ナビゲーション
- `<leader>hs`: Hunk をステージ
- `<leader>hr`: Hunk をリセット
- `<leader>hp`: Hunk をプレビュー

### 診断

- `]d` / `[d`: 診断ナビゲーション
- `<leader>e`: 診断表示
- `<leader>xx`: Trouble 切り替え

### バッファ管理

- `<S-h>` / `<S-l>`: バッファ切り替え
- `<leader>bo`: 他のバッファを閉じる
- `<leader>bp`: バッファピン留め

### ターミナル

- `<C-\>`: ターミナル切り替え
- `<leader>tf`: フローティングターミナル
- `<leader>th`: 水平ターミナル
- `<leader>tv`: 垂直ターミナル

## セットアップ手順

1. **既存の設定をバックアップ**

   ```bash
   mv ~/.config/nvim ~/.config/nvim.bak
   ```

2. **新しい設定ディレクトリを作成**

   ```bash
   mkdir -p ~/.config/nvim/lua/{config,plugins}
   ```

3. **設定ファイルを配置**

   - 提供されたファイルを適切な場所に配置

4. **Neovim を起動**

   ```bash
   nvim
   ```

   初回起動時に自動的に lazy.nvim とプラグインがインストールされます。

5. **LSP サーバーのインストール**

   ```txt
   :Mason
   ```

   で Mason を開き、必要な LSP サーバーをインストール

## カスタマイズのヒント

### 新しいプラグインの追加

`lua/plugins/`ディレクトリに新しい`.lua`ファイルを作成し、プラグイン設定を記述してください。

### キーバインドの変更

各プラグインの設定ファイル内の keys セクションを編集するか、`init.lua`に追加してください。

### カラースキームの変更

`lua/plugins/colorscheme.lua`を編集して、お好みのカラースキームに変更できます。

### LSP サーバーの追加

`lua/plugins/lsp.lua`の`servers`テーブルに新しいサーバー設定を追加してください。

## トラブルシューティング

### プラグインが読み込まれない

- `:Lazy`でプラグインマネージャーを開いて状態を確認
- `:Lazy sync`で同期を実行

### LSP が動作しない

- `:LspInfo`で LSP 状態を確認
- `:Mason`で必要なサーバーがインストールされているか確認

### パフォーマンスが悪い

- 大きなファイルでは Treesitter が自動的に無効化されます
- `vim.g.loaded_*`設定で不要なプラグインを無効化済み

## 推奨システム要件

- Neovim 0.9.0+
- Git
- ripgrep (telescope 検索用)
- fd (telescope 検索用、オプション)
- make (telescope-fzf-native 用)
- Node.js (一部 LSP 用)
