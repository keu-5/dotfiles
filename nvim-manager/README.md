# Neovim Manager

Neovim 環境のセットアップと管理を行うディレクトリです。

## 概要

このディレクトリには、Neovim 環境の初期設定と管理に必要なスクリプトが含まれています。

## ファイル構成

```text
nvim-manager/
├── README.md           # このファイル
└── setup-nvim.sh      # Neovim環境セットアップスクリプト
```

## 使用方法

### Neovim 環境のセットアップ

```bash
./nvim-manager/setup-nvim.sh
```

このスクリプトは以下の処理を行います：

1. **前提条件の確認**

   - Homebrew の存在確認
   - Neovim のインストール（存在しない場合）

2. **設定ファイルのリンク作成**

   - `~/.config/nvim` → `dotfiles/.config/nvim` のシンボリックリンク作成
   - 既存の設定がある場合は自動的にバックアップを作成

3. **設定の検証**
   - リンクが正常に作成されたことを確認

## 注意事項

- このスクリプトを実行する前に、Homebrew がインストールされている必要があります
- 既存の `~/.config/nvim` がある場合、自動的にバックアップが作成されます
- バックアップファイル名には日時が含まれ、重複を避けます

## トラブルシューティング

### Homebrew が見つからない場合

```bash
./homebrew/setup.sh
```

を先に実行して Homebrew をインストールしてください。

### リンク作成に失敗した場合

1. 手動でバックアップを確認：

   ```bash
   ls -la ~/.config/nvim*
   ```

2. 手動でリンクを削除：

   ```bash
   rm ~/.config/nvim
   ```

3. スクリプトを再実行：

   ```bash
   ./nvim-manager/setup-nvim.sh
   ```
