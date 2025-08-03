#!/bin/bash
set -e

echo "🔧 LaTeX環境のセットアップを開始します..."

# スクリプト自体の実行権限を確認
if [[ ! -x "$0" ]]; then
  echo "Warning: このスクリプトに実行権限がありません。"
  echo "実行権限を付与してから再実行してください: chmod +x setup-latex.sh"
  exit 1
fi

# MacTeX のインストール確認
if ! command -v latex &>/dev/null || ! command -v tlmgr &>/dev/null; then
    echo "📋 MacTeX がインストールされていません。"
    echo "📥 以下のURLからMacTeXをダウンロードしてインストールしてください："
    echo "   https://tug.org/mactex/mactex-download.html"
    echo ""
    echo "⚠️  MacTeXをインストール後、このスクリプトを再実行してください。"
    echo "    インストールには数GB必要で、時間がかかります。"
    exit 1
fi

echo "✅ MacTeX が見つかりました。"

# TeXライブインストールディレクトリを確認
if [[ -d "/usr/local/texlive" ]]; then
    # macOS Intel版の場合
    TEXLIVE_PATH="/usr/local/texlive"
elif [[ -d "/opt/homebrew/texlive" ]]; then
    # macOS Apple Silicon版（Homebrew経由）の場合
    TEXLIVE_PATH="/opt/homebrew/texlive"
else
    # 標準的なパスを確認
    TEXLIVE_PATH=$(find /usr/local -name "texlive" -type d 2>/dev/null | head -1)
fi

if [[ -n "$TEXLIVE_PATH" ]]; then
    echo "📍 TeXライブディレクトリ: $TEXLIVE_PATH"
fi

# tlmgr の更新
echo "🔄 tlmgr と全パッケージを更新しています..."
if sudo tlmgr update --self --all; then
    echo "✅ tlmgr とパッケージの更新が完了しました。"
else
    echo "⚠️  tlmgr の更新で一部エラーが発生しましたが、続行します。"
fi

# 用紙サイズをA4に設定
echo "📄 用紙サイズをA4に設定しています..."
if sudo tlmgr paper a4; then
    echo "✅ 用紙サイズをA4に設定しました。"
else
    echo "⚠️  用紙サイズの設定でエラーが発生しました。"
fi

# 必要なPerlモジュールのインストール
echo "🐪 必要なPerlモジュールをインストールしています..."

# File::HomeDir のインストール
echo "  📦 File::HomeDir をインストール中..."
if cpan -i File::HomeDir; then
    echo "  ✅ File::HomeDir をインストールしました。"
else
    echo "  ⚠️  File::HomeDir のインストールでエラーが発生しました。"
fi

# YAML::Tiny のインストール
echo "  📦 YAML::Tiny をインストール中..."
if cpan -i YAML::Tiny; then
    echo "  ✅ YAML::Tiny をインストールしました。"
else
    echo "  ⚠️  YAML::Tiny のインストールでエラーが発生しました。"
fi

# .latexmkrc の確認
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "$DOTFILES_DIR/.latexmkrc" ]]; then
    echo "📝 .latexmkrc の設定を確認しています..."
    
    # 既存の .latexmkrc があるかチェック
    if [[ -f "$HOME/.latexmkrc" ]] || [[ -L "$HOME/.latexmkrc" ]]; then
        echo "  🔄 既存の .latexmkrc を更新しています..."
        rm -f "$HOME/.latexmkrc"
    fi
    
    # シンボリックリンクを作成（install.shで既に作成されている可能性があるが、念のため）
    if ln -sf "$DOTFILES_DIR/.latexmkrc" "$HOME/.latexmkrc"; then
        echo "  ✅ .latexmkrc をホームディレクトリにリンクしました。"
    else
        echo "  ⚠️  .latexmkrc のリンク作成でエラーが発生しました。"
    fi
else
    echo "  ❌ .latexmkrc が dotfiles ディレクトリに見つかりません。"
fi

# LaTeX 動作確認
echo "🧪 LaTeX の動作確認をしています..."
if platex --version &>/dev/null; then
    echo "✅ platex が正常に動作しています。"
else
    echo "⚠️  platex の動作確認でエラーが発生しました。"
fi

if dvipdfmx --version &>/dev/null; then
    echo "✅ dvipdfmx が正常に動作しています。"
else
    echo "⚠️  dvipdfmx の動作確認でエラーが発生しました。"
fi

echo ""
echo "🎉 LaTeX環境のセットアップが完了しました！"
echo ""
echo "📚 使用方法："
echo "   latexmk -pvc document.tex  # 自動コンパイル・プレビュー"
echo "   latexmk -c                 # 一時ファイルの削除"
echo "   latexmk -C                 # 全生成ファイルの削除"
echo ""
echo "🔧 設定ファイル："
echo "   ~/.latexmkrc - LaTeXmk設定（日本語LaTeX用に最適化済み）"
