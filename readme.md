# dotfiles

このリポジトリは、自分の開発環境の設定ファイル（dotfiles）をまとめて管理するためのものです。  
Neovim、zsh などの設定を含みます。

## 📦 管理している主なファイル・ディレクトリ

| ツール | 設定ファイル／ディレクトリ        |
| ------ | --------------------------------- |
| Neovim | `.config/nvim/`                   |
| zsh    | `.zshrc`                          |
| LaTeX  | `.config/nvim/`（LaTeX 設定含む） |
| その他 | 必要に応じて追加                  |

## 🛠️ セットアップ方法

Homebrew が必要です。

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

git clone https://github.com/yourname/dotfiles.git

cd 任意の場所

chmod +x install.sh && ./install.sh
```

このコマンドにより、各設定ファイルが以下のように **シンボリックリンクで配置**されます：

```txt
~/.config/nvim        → dotfiles/.config/nvim
~/.zshrc              → dotfiles/.zshrc
```

> ※ すでにリンク先が存在する場合は上書きされます（安全のため事前にバックアップを推奨）

### フォントの設定

`install.sh`でフォントがインストールされます。`Hack Nerd Font Mono`を設定してください

## ✅ Homebrew で自動インストールされるもの

- zsh-autosuggestions
- zsh-completions
- python@3.13
- nodebrew

## 📄 LaTeX 設定

LaTeX の設定は Neovim の設定に含まれています。以下のキーバインドが利用可能です：

### キーバインド

| キー            | 機能                               |
| --------------- | ---------------------------------- |
| `Cmd + Opt + B` | LaTeX ファイルのビルド（PDF 生成） |
| `Cmd + Opt + V` | PDF プレビューの表示               |

### 必要なソフトウェア

LaTeX を使用するには以下がインストールされている必要があります：

```bash
# MacTeX のインストール（推奨）
brew install --cask mactex

# または BasicTeX + 必要なパッケージ
brew install --cask basictex
sudo tlmgr update --self
sudo tlmgr install latexmk
```

### 使用方法

1. `.tex` ファイルを Neovim で開く
2. `Cmd + Opt + B` でビルド実行
3. `Cmd + Opt + V` で生成された PDF を確認

> ※ ビルドには latexmk が使用されます。エラーが発生した場合は、必要な LaTeX パッケージがインストールされているか確認してください。

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

---

必要に応じて `uninstall.sh`（リンク削除用）や `check.sh`（リンク確認用）も追加予定。
