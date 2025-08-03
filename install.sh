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

# スクリプト自身のディレクトリを基準にする
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${CYAN}🚀 Dotfiles セットアップを開始します${NC}"
log_info "Using dotfiles directory: $DOTFILES_DIR"

# スクリプト自体の実行権限を確認
if [[ ! -x "$0" ]]; then
  log_error "このスクリプトに実行権限がありません。"
  log_info "実行権限を付与してから再実行してください: chmod +x install.sh"
  exit 1
fi

log_section "前提条件の確認"
if ! command -v brew &>/dev/null; then
  log_error "Homebrew が見つかりません。"
  log_info "先に homebrew/setup.sh を実行してください："
  echo -e "${YELLOW}   ./homebrew/setup.sh${NC}"
  exit 1
fi
log_success "Homebrew が見つかりました"

log_section "Dotfiles シンボリックリンク作成"

# .zshrc のリンク作成
log_info "~/.zshrc のシンボリックリンクを作成しています..."
if [[ -e ~/.zshrc ]] && [[ ! -L ~/.zshrc ]]; then
  backup_name="~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
  log_warning "~/.zshrc が既に存在します。バックアップを作成します: $backup_name"
  mv ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
fi
ln -sfn "$DOTFILES_DIR/.zshrc" ~/.zshrc
log_success "~/.zshrc のリンクを作成しました"

echo ""
log_section "セットアップ完了"
log_success "基本的な開発環境セットアップが完了しました！"
echo -e "${GREEN}   ✓${NC} 設定ファイルがリンクされました"
echo ""
log_info "追加の環境セットアップ："
echo -e "${BLUE}   ./nvim-manager/setup-nvim.sh${NC}     - Neovim環境のセットアップ"
echo -e "${BLUE}   ./vscode-manager/setup-vscode.sh${NC} - VS Code環境のセットアップ"
echo -e "${BLUE}   ./latex/setup-latex.sh${NC}           - LaTeX環境のセットアップ"

# zsh 再起動で設定を反映
echo ""
log_info "設定を反映するため zsh を再起動します..."
echo -e "${CYAN}🎉 すべてのセットアップが完了しました！${NC}"
exec zsh
