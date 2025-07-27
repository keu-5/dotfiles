#!/bin/bash

# スクリプト自身のディレクトリを基準にする
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Using dotfiles directory: $DOTFILES_DIR"

# Homebrew 確認
if ! command -v brew &>/dev/null; then
  echo "Homebrew が見つかりません。https://brew.sh を参照してインストールしてください。"
  exit 1
fi

# dotfiles のシンボリックリンク作成
ln -sfn "$DOTFILES_DIR/.config/nvim" ~/.config/nvim
ln -sfn "$DOTFILES_DIR/.zshrc" ~/.zshrc

# 必須ツールのインストール
brew install zsh-autosuggestions zsh-completions python@3.13 nodebrew || true

# zsh 再起動で設定を反映
echo "🚀 設定を反映するため zsh を再起動します..."
exec zsh
