#!/bin/bash
set -e

# ログ出力用の色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ログ関数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_section() {
    echo -e "\n${PURPLE}==== $1 ====${NC}"
}

echo -e "${CYAN}� LaTeX 環境セットアップを開始します${NC}"

# スクリプト自体の実行権限を確認
if [[ ! -x "$0" ]]; then
  log_error "このスクリプトに実行権限がありません。"
  log_info "実行権限を付与してから再実行してください: chmod +x setup-latex.sh"
  exit 1
fi

log_section "MacTeX インストール確認"
if ! command -v latex &>/dev/null || ! command -v tlmgr &>/dev/null; then
    log_error "MacTeX がインストールされていません。"
    echo ""
    log_info "以下のURLからMacTeXをダウンロードしてインストールしてください："
    echo -e "${YELLOW}   https://tug.org/mactex/mactex-download.html${NC}"
    echo ""
    log_warning "MacTeXをインストール後、このスクリプトを再実行してください。"
    log_info "インストールには数GB必要で、時間がかかります。"
    exit 1
fi

log_success "MacTeX が見つかりました"

log_section "TeX Live ディレクトリ確認"
if [[ -d "/usr/local/texlive" ]]; then
    # macOS Intel版の場合
    TEXLIVE_PATH="/usr/local/texlive"
    log_info "TeXライブディレクトリ (Intel): $TEXLIVE_PATH"
elif [[ -d "/opt/homebrew/texlive" ]]; then
    # macOS Apple Silicon版（Homebrew経由）の場合
    TEXLIVE_PATH="/opt/homebrew/texlive"
    log_info "TeXライブディレクトリ (Apple Silicon): $TEXLIVE_PATH"
else
    # 標準的なパスを確認
    TEXLIVE_PATH=$(find /usr/local -name "texlive" -type d 2>/dev/null | head -1)
    if [[ -n "$TEXLIVE_PATH" ]]; then
        log_info "TeXライブディレクトリ: $TEXLIVE_PATH"
    else
        log_warning "TeXライブディレクトリが見つかりませんでした"
    fi
fi

log_section "tlmgr とパッケージの更新"
UPDATE_MARKER="$HOME/.tlmgr_updated"

if [[ -f "$UPDATE_MARKER" ]]; then
    log_info "tlmgr とパッケージの更新は既に実行済みです（$UPDATE_MARKER を削除すれば再実行します）"
else
    log_info "tlmgr と全パッケージを更新しています（時間がかかる場合があります）..."
    if sudo tlmgr update --self --all >/dev/null 2>&1; then
        log_success "tlmgr とパッケージの更新が完了しました"
        date > "$UPDATE_MARKER"
    else
        log_warning "tlmgr の更新で一部エラーが発生しましたが、続行します"
    fi
fi

log_section "用紙サイズ設定"
log_info "用紙サイズをA4に設定しています..."
if sudo tlmgr paper a4 >/dev/null 2>&1; then
    log_success "用紙サイズをA4に設定しました"
else
    log_warning "用紙サイズの設定でエラーが発生しました"
fi

log_section "Perl モジュールのインストール"

# File::HomeDir のインストール
log_info "File::HomeDir をインストールしています..."
if cpan -i File::HomeDir >/dev/null 2>&1; then
    log_success "File::HomeDir をインストールしました"
else
    log_warning "File::HomeDir のインストールでエラーが発生しました"
fi

# YAML::Tiny のインストール
log_info "YAML::Tiny をインストールしています..."
if cpan -i YAML::Tiny >/dev/null 2>&1; then
    log_success "YAML::Tiny をインストールしました"
else
    log_warning "YAML::Tiny のインストールでエラーが発生しました"
fi

log_section ".latexmkrc 設定確認"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LATEXRC_SRC="${LATEXRC_SRC:-"$SCRIPT_DIR/.latexmkrc"}"

if [[ -f "$LATEXRC_SRC" ]]; then
    log_info ".latexmkrc の設定を確認しています..."

    if [[ -f "$HOME/.latexmkrc" ]] || [[ -L "$HOME/.latexmkrc" ]]; then
        log_warning "既存の .latexmkrc を更新しています..."
        rm -f "$HOME/.latexmkrc"
    fi

    if ln -sf "$LATEXRC_SRC" "$HOME/.latexmkrc"; then
        log_success ".latexmkrc をホームディレクトリにリンクしました → $LATEXRC_SRC"
    else
        log_error ".latexmkrc のリンク作成でエラーが発生しました"
    fi
else
    log_error ".latexmkrc が見つかりません: $LATEXRC_SRC"
    log_info  "場所が違う場合は LATEXRC_SRC=/path/to/.latexmkrc として再実行してください"
fi

log_section "LaTeX 動作確認"
log_info "LaTeX の動作確認をしています..."

if platex --version &>/dev/null; then
    log_success "platex が正常に動作しています"
else
    log_warning "platex の動作確認でエラーが発生しました"
fi

if dvipdfmx --version &>/dev/null; then
    log_success "dvipdfmx が正常に動作しています"
else
    log_warning "dvipdfmx の動作確認でエラーが発生しました"
fi

echo ""
log_section "セットアップ完了"
echo -e "${CYAN}🎉 LaTeX 環境のセットアップが完了しました！${NC}"
echo ""
echo -e "${GREEN}📚 使用方法：${NC}"
echo -e "${BLUE}   latexmk -pvc document.tex${NC}  # 自動コンパイル・プレビュー"
echo -e "${BLUE}   latexmk -c${NC}                 # 一時ファイルの削除"
echo -e "${BLUE}   latexmk -C${NC}                 # 全生成ファイルの削除"
echo ""
echo -e "${GREEN}🔧 設定ファイル：${NC}"
echo -e "${BLUE}   ~/.latexmkrc${NC} - LaTeXmk設定（日本語LaTeX用に最適化済み）"
