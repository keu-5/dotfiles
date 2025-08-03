# VS Code Manager

VS Code関連の設定とセットアップを統合的に管理するディレクトリです。

## 📁 ディレクトリ構成

```text
vscode-manager/
├── setup-vscode.sh      # VS Code環境セットアップスクリプト
├── settings.json        # VS Code設定ファイル
├── keybindings.json     # キーバインド設定
├── extensions.txt       # 拡張機能リスト
├── snippets/           # スニペット集
└── README.md           # このファイル
```

## 🚀 使用方法

### VS Code環境のセットアップ

```bash
# VS Code環境の完全セットアップ
./vscode-manager/setup-vscode.sh
```

このスクリプトは以下を実行します：

1. **VS Codeのインストール確認**
   - VS Codeがインストールされていない場合はHomebrewでインストール
   - コマンドラインツール（`code`コマンド）のセットアップ

2. **拡張機能のインストール**
   - `extensions.txt` に記載された拡張機能を一括インストール

3. **設定ファイルのリンク作成**
   - `settings.json` - VS Code設定
   - `keybindings.json` - キーバインド設定
   - `snippets/` - スニペット集

## 📝 拡張機能管理

### 拡張機能の追加

1. `extensions.txt` に拡張機能IDを追加
2. セットアップスクリプトを再実行

```bash
# 現在インストールされている拡張機能リストを取得
code --list-extensions > extensions.txt
```

### 手動で拡張機能をインストール

```bash
code --install-extension <extension-id>
```

## ⚙️ 設定ファイル

### settings.json

- Python、LaTeX、Markdown等の言語固有設定
- Neovim統合設定
- GitHub Copilot設定
- テーマとアイコン設定

### keybindings.json

- カスタムキーバインド設定（現在は空）

## 🔗 連携機能

### Neovim統合

- `vscode-neovim`拡張機能によるNeovim統合
- `jj`によるエスケープキー設定
- Hack Nerd Fontの使用

### GitHub Copilot

- 次の編集候補機能が有効
- チャット機能との連携

### LaTeX Workshop

- 日本語LaTeX環境への最適化
- latexmkとの連携設定

## 🔧 トラブルシューティング

### VS Codeコマンドが見つからない場合

```bash
# PATHに手動追加
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
```

### 設定ファイルがリンクされない場合

```bash
# 既存ファイルを削除してから再実行
rm -f "$HOME/Library/Application Support/Code/User/settings.json"
./vscode-manager/setup-vscode.sh
```

## 📚 参考リンク

- [VS Code公式ドキュメント](https://code.visualstudio.com/docs)
- [vscode-neovim拡張機能](https://github.com/VSCodeVim/Vim)
- [LaTeX Workshop](https://github.com/James-Yu/LaTeX-Workshop)
