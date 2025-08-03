# LaTeX 設定

このディレクトリには LaTeX 関連の設定ファイルとセットアップスクリプトが含まれています。

## ファイル構成

- `.latexmkrc` - LaTeXmk の設定ファイル（日本語 LaTeX 用に最適化）
- `setup-latex.sh` - LaTeX 環境のセットアップスクリプト

## セットアップ

### 前提条件

- macOS
- MacTeX のインストール

### 使用方法

1. LaTeX 環境のセットアップ:

   ```bash
   cd latex
   chmod +x setup-latex.sh
   ./setup-latex.sh
   ```

2. `.latexmkrc` の手動設定（セットアップスクリプトで自動実行されます）:

   ```bash
   ln -sf $(pwd)/.latexmkrc ~/.latexmkrc
   ```

## LaTeX 環境の詳細セットアップ

このスクリプトは以下を実行します：

- MacTeX のインストール確認
- tlmgr とパッケージの更新
- 用紙サイズの A4 設定
- 必要な Perl モジュール（File::HomeDir, YAML::Tiny）のインストール
- .latexmkrc の設定確認

## 必要なソフトウェア

LaTeX を使用するには以下がインストールされている必要があります：

```bash
# MacTeX のインストール（推奨）
# 以下のURLから直接ダウンロードしてインストール：
# https://tug.org/mactex/mactex-download.html

# または BasicTeX + 必要なパッケージ
brew install --cask basictex
sudo tlmgr update --self
sudo tlmgr install latexmk
```

## キーバインド（Neovim）

| キー            | 機能                               |
| --------------- | ---------------------------------- |
| `Cmd + Opt + B` | LaTeX ファイルのビルド（PDF 生成） |
| `Cmd + Opt + V` | PDF プレビューの表示               |

## Neovim での使用方法

1. `.tex` ファイルを Neovim で開く
2. `Cmd + Opt + B` でビルド実行
3. `Cmd + Opt + V` で生成された PDF を確認

> ※ ビルドには latexmk が使用されます。エラーが発生した場合は、必要な LaTeX パッケージがインストールされているか確認してください。

## LaTeXmk の使用方法

- 自動コンパイル・プレビュー: `latexmk -pvc document.tex`
- 一時ファイルの削除: `latexmk -c`
- 全生成ファイルの削除: `latexmk -C`

## 設定内容

### .latexmkrc

- pLaTeX + dvipdfmx を使用した日本語 LaTeX 処理
- BibTeX: pbibtex
- Index: mendex
- SyncTeX 有効
- macOS 向けプレビューワー設定
