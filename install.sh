#!/bin/bash
set -e

# スクリプト自身のディレクトリを基準にする
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Using dotfiles directory: $DOTFILES_DIR"

# スクリプト自体の実行権限を確認
if [[ ! -x "$0" ]]; then
  echo "Warning: このスクリプトに実行権限がありません。"
  echo "実行権限を付与してから再実行してください: chmod +x install.sh"
  exit 1
fi

# Homebrew 確認
if ! command -v brew &>/dev/null; then
  echo "Homebrew が見つかりません。https://brew.sh を参照してインストールしてください。"
  exit 1
fi

# VS Code のインストール（Homebrew経由）
if ! command -v code &>/dev/null; then
  echo "Installing Visual Studio Code..."
  brew install --cask visual-studio-code
  
  # VS Code の code コマンドを PATH に追加
  echo "Setting up VS Code command line tools..."
  if [[ ":$PATH:" != *":/Applications/Visual Studio Code.app/Contents/Resources/app/bin:"* ]]; then
    export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
  fi
  
  # VS Code が正常にインストールされたか確認
  if ! command -v code &>/dev/null; then
    echo "Warning: VS Code command line tools may need manual setup."
    echo "Please run: 'code --version' to verify installation."
  fi
fi

# dotfiles のシンボリックリンク作成
echo "Creating symbolic links for dotfiles..."

# .config/nvim のリンク作成
if [[ -e ~/.config/nvim ]] && [[ ! -L ~/.config/nvim ]]; then
  echo "Warning: ~/.config/nvim already exists and is not a symlink. Creating backup..."
  mv ~/.config/nvim ~/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)
fi
ln -sfn "$DOTFILES_DIR/.config/nvim" ~/.config/nvim

# .zshrc のリンク作成
if [[ -e ~/.zshrc ]] && [[ ! -L ~/.zshrc ]]; then
  echo "Warning: ~/.zshrc already exists and is not a symlink. Creating backup..."
  mv ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
fi
ln -sfn "$DOTFILES_DIR/.zshrc" ~/.zshrc

# VS Code 設定ファイルのリンク
echo "Linking VS Code settings..."
VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"

# VS Code設定ディレクトリを適切な権限で作成
mkdir -p "$VSCODE_USER_DIR"
chmod 755 "$VSCODE_USER_DIR"

# 既存のsettings.jsonを削除してからリンクを作成
if [ -f "$VSCODE_USER_DIR/settings.json" ] || [ -L "$VSCODE_USER_DIR/settings.json" ]; then
  echo "Removing existing settings.json..."
  rm -f "$VSCODE_USER_DIR/settings.json"
fi

ln -sf "$DOTFILES_DIR/vscode/settings.json" "$VSCODE_USER_DIR/settings.json"

# 既存のkeybindings.jsonを削除してからリンクを作成
if [ -f "$VSCODE_USER_DIR/keybindings.json" ] || [ -L "$VSCODE_USER_DIR/keybindings.json" ]; then
  echo "Removing existing keybindings.json..."
  rm -f "$VSCODE_USER_DIR/keybindings.json"
fi

ln -sf "$DOTFILES_DIR/vscode/keybindings.json" "$VSCODE_USER_DIR/keybindings.json"

# 既存のsnippetsディレクトリを削除してからリンクを作成
if [ -d "$VSCODE_USER_DIR/snippets" ] || [ -L "$VSCODE_USER_DIR/snippets" ]; then
  echo "Removing existing snippets directory..."
  rm -rf "$VSCODE_USER_DIR/snippets"
fi

ln -snf "$DOTFILES_DIR/vscode/snippets" "$VSCODE_USER_DIR/snippets"

# 必須ツールのインストール
brew install zsh-autosuggestions zsh-completions python@3.13 nodebrew neovim || true
brew install --cask font-hack-nerd-font

# VS Code 拡張機能のインストール
echo "Installing VS Code extensions..."
if [ -f "$DOTFILES_DIR/vscode/extensions.txt" ]; then
  extension_count=0
  failed_extensions=()
  
  while IFS= read -r extension; do
    # 空行やコメント行をスキップ
    if [[ -n "$extension" && ! "$extension" =~ ^[[:space:]]*# ]]; then
      echo "Installing extension: $extension"
      if code --install-extension "$extension"; then
        ((extension_count++))
        echo "✅ Successfully installed: $extension"
      else
        failed_extensions+=("$extension")
        echo "❌ Failed to install: $extension"
      fi
    fi
  done < "$DOTFILES_DIR/vscode/extensions.txt"
  
  echo "Extension installation summary:"
  echo "✅ Successfully installed: $extension_count extensions"
  if [ ${#failed_extensions[@]} -gt 0 ]; then
    echo "❌ Failed to install: ${#failed_extensions[@]} extensions"
    printf '   - %s\n' "${failed_extensions[@]}"
  fi
else
  echo "Warning: extensions.txt not found in $DOTFILES_DIR/vscode/"
fi

echo "✅ VS Code setup complete."
echo "   - Settings, keybindings, and snippets linked"
echo "   - Extensions installed (see summary above)"
echo "   - Neovim integration ready"

# zsh 再起動で設定を反映
echo "🚀 設定を反映するため zsh を再起動します..."
exec zsh
