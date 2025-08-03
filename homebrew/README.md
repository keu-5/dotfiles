# Homebrew Configuration

このディレクトリは Homebrew 関連の設定とスクリプトを管理します。

## ファイル構成

- `setup.sh` - Homebrew のセットアップスクリプト
- `Brewfile` - パッケージ定義ファイル（brew bundle 用）

## 使用方法

### 初回セットアップ

```bash
# Homebrew と全パッケージのインストール
./homebrew/setup.sh
```

### パッケージ管理

```bash
# 現在インストール済みのパッケージをBrewfileに保存
brew bundle dump --file=homebrew/Brewfile --force

# Brewfileからパッケージを一括インストール
brew bundle install --file=homebrew/Brewfile

# Brewfileで管理されていないパッケージをクリーンアップ
brew bundle cleanup --file=homebrew/Brewfile
```

## Brewfile について

Brewfile には以下が含まれています：

### Core Development Tools

- Git, Neovim
- Shell enhancements (zsh-autosuggestions, zsh-completions)
- Programming languages (Python, Node.js, Ruby)

### Development Utilities

- Package managers (pipx, uv)
- File utilities (tree)

### Optional Tools

- Container tools (Docker, Colima)
- Database (MySQL)
- Graphics (Graphviz)

### Fonts

- Hack Nerd Font
- Fira Code

### VS Code Extensions

- Core extensions (Copilot, Neovim integration)
- Language support (Python, LaTeX, Web development)
- Themes and utilities

## カスタマイズ

新しいパッケージや VS Code 拡張機能を追加したい場合は、Brewfile を直接編集するか、以下のコマンドで現在の環境から自動生成できます：

```bash
# 現在の環境をBrewfileに反映
brew bundle dump --file=homebrew/Brewfile --force
```
