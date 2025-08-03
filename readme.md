# dotfiles

このリポジトリは、自分の開発環境の設定ファイル（dotfiles）をまとめて管理するためのものです。  
Neovim、zsh などの設定を含みます。

## 📦 管理している主なファイル・ディレクトリ

| ツール   | 設定ファイル／ディレクトリ | セットアップスクリプト           |
| -------- | -------------------------- | -------------------------------- |
| Homebrew | `homebrew/`                | `homebrew/setup.sh`              |
| Neovim   | `.config/nvim/`            | `install.sh`                     |
| zsh      | `.zshrc`                   | `install.sh`                     |
| VS Code  | `vscode-manager/`          | `vscode-manager/setup-vscode.sh` |
| LaTeX    | `latex/`                   | `latex/setup-latex.sh`           |
| その他   | 必要に応じて追加           | -                                |

## 🛠️ セットアップ方法

以下の順序で実行してください：

```shell
git clone https://github.com/yourname/dotfiles.git
cd dotfiles

# 0. 環境の検証（オプション）
chmod +x validate.sh && ./validate.sh

# 1. Homebrew と必須ツールのセットアップ
chmod +x homebrew/setup.sh && ./homebrew/setup.sh

# 2. 基本的な開発環境のセットアップ（Neovim、zsh）
chmod +x install.sh && ./install.sh

# 3. VS Code環境のセットアップ（必要に応じて）
chmod +x vscode-manager/setup-vscode.sh && ./vscode-manager/setup-vscode.sh

# 4. LaTeX環境のセットアップ（必要に応じて）
cd latex && chmod +x setup-latex.sh && ./setup-latex.sh && cd ..
```

基本セットアップ（`install.sh`）により、各設定ファイルが以下のように **シンボリックリンクで配置**されます：

```txt
~/.config/nvim        → dotfiles/.config/nvim
~/.zshrc              → dotfiles/.zshrc
```

LaTeX 関連の設定（`latex/`ディレクトリ）は`latex/setup-latex.sh`で別途処理されます。

> ※ すでにリンク先が存在する場合は、タイムスタンプ付きでバックアップされます  
> ※ スクリプトは実行権限の確認を自動で行います

### フォントの設定

`homebrew/setup.sh`でフォントがインストールされます。`Hack Nerd Font Mono`または`Fira Code`を設定してください

## ✅ 各スクリプトでインストールされるもの

### homebrew/setup.sh

- **基本ツール**: git, zsh-autosuggestions, zsh-completions, python@3.13, nodebrew, neovim
- **フォント**: Hack Nerd Font
- **追加ツール**: tree, docker, mysql, graphviz など

### install.sh

- Neovim 設定ファイル（.config/nvim/）のシンボリックリンク作成
- zsh 設定ファイル（.zshrc）のシンボリックリンク作成
- 基本的な開発環境の準備

### vscode-manager/setup-vscode.sh

- VS Code のインストール（未インストールの場合）
- VS Code 拡張機能の一括インストール
- VS Code 設定ファイルのリンク

### latex/setup-latex.sh

- MacTeX の確認とセットアップ
- tlmgr とパッケージの更新
- 用紙サイズの A4 設定
- 必要な Perl モジュール
- .latexmkrc の設定

> 📄 **LaTeX の詳細設定**: キーバインド、使用方法、必要なソフトウェアについては [`latex/README.md`](latex/README.md) を参照してください。

## 🧼 注意点

- `.config` 以下でも **個人情報を含む設定（例: GitHub CLI, AWS CLI 等）は含めていません**
- `.gitignore` によって除外対象を制御しています

## 💡 補足

- シンボリックリンクが正しく貼られているかは以下のコマンドで確認できます：

```bash
ls -l ~/.config/nvim

あるいは

readlink ~/.zshrc
```

## 🔧 パッケージ管理

Homebrew のパッケージ管理には以下のコマンドが便利です：

```bash
# 現在インストール済みのパッケージをBrewfileに保存
brew bundle dump --file=homebrew/Brewfile --force

# Brewfileからパッケージを一括インストール
brew bundle install --file=homebrew/Brewfile

# Brewfileで管理されていないパッケージをクリーンアップ
brew bundle cleanup --file=homebrew/Brewfile
```

---

必要に応じて `uninstall.sh`（リンク削除用）や `check.sh`（リンク確認用）も追加予定。
