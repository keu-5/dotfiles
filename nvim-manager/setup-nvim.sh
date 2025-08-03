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

# スクリプト自身のディレクトリを基準にdotfilesディレクトリを特定
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${CYAN}🚀 Neovim セットアップを開始します${NC}"
log_info "Using dotfiles directory: $DOTFILES_DIR"

log_section "前提条件の確認"

# Homebrew の確認
if ! command -v brew &>/dev/null; then
  log_error "Homebrew が見つかりません。"
  log_info "先に homebrew/setup.sh を実行してください："
  echo -e "${YELLOW}   $DOTFILES_DIR/homebrew/setup.sh${NC}"
  exit 1
fi
log_success "Homebrew が見つかりました"

# Neovim の確認
if ! command -v nvim &>/dev/null; then
  log_warning "Neovim が見つかりません。インストールします..."
  brew install neovim
  log_success "Neovim をインストールしました"
else
  log_success "Neovim が見つかりました ($(nvim --version | head -n1))"
fi

log_section "Neovim 設定のシンボリックリンク作成"

# ~/.config ディレクトリの確認・作成
if [[ ! -d ~/.config ]]; then
  log_info "~/.config ディレクトリを作成しています..."
  mkdir -p ~/.config
  log_success "~/.config ディレクトリを作成しました"
fi

# .config/nvim のリンク作成
log_info "~/.config/nvim のシンボリックリンクを作成しています..."
if [[ -e ~/.config/nvim ]] && [[ ! -L ~/.config/nvim ]]; then
  backup_name="~/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
  log_warning "~/.config/nvim が既に存在します。バックアップを作成します: $backup_name"
  mv ~/.config/nvim ~/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)
fi

# シンボリックリンクの作成
ln -sfn "$DOTFILES_DIR/.config/nvim" ~/.config/nvim
log_success "~/.config/nvim のリンクを作成しました"

# Neovim設定の検証
log_section "設定の検証"
if [[ -L ~/.config/nvim ]] && [[ -d "$DOTFILES_DIR/.config/nvim" ]]; then
  log_success "Neovim設定のリンクが正常に作成されました"
  log_info "リンク先: $(readlink ~/.config/nvim)"
else
  log_error "Neovim設定のリンク作成に失敗しました"
  exit 1
fi

echo ""
log_section "Neovim セットアップ完了"
log_success "Neovim環境のセットアップが完了しました！"
echo -e "${GREEN}   ✓${NC} Neovim設定ファイルがリンクされました"
echo -e "${GREEN}   ✓${NC} Neovim統合の準備が完了しました"
echo ""
log_info "Neovimを起動して設定を確認してください："
echo -e "${BLUE}   nvim${NC}"
