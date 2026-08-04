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

echo -e "${CYAN}🚀 tmux セットアップを開始します${NC}"
log_info "Using dotfiles directory: $DOTFILES_DIR"

log_section "前提条件の確認"

# tmux の確認
# ※ このスクリプトは tmux を自動インストールしない。
#    パッケージの導入は環境ごとに方法が違い、勝手に走らせたくないため。
if ! command -v tmux &>/dev/null; then
  log_error "tmux が見つかりません。先にインストールしてください。"
  echo -e "${YELLOW}   macOS: brew install tmux${NC}"
  echo -e "${YELLOW}   Ubuntu/Debian: sudo apt install tmux${NC}"
  exit 1
fi

TMUX_VERSION="$(tmux -V | awk '{print $2}')"          # 例: 3.2a
TMUX_VERSION_NUM="${TMUX_VERSION//[^0-9.]/}"          # 例: 3.2
log_success "tmux が見つかりました (tmux $TMUX_VERSION)"

# 設定ファイルの置き場所を決める。
# tmux は 3.1 以降 ~/.config/tmux/tmux.conf も探索パスに含む（上流 CHANGES / Makefile.am）。
# 探索パスは「最初に見つかった1つ」ではなく、存在するファイルを順に全部読む。
# ~/.config/tmux/tmux.conf は ~/.tmux.conf より後に読まれるため、同じ設定なら後者が上書きされる。
# 3.1 より古い tmux はこのパスを見ないので、その場合は ~/.tmux.conf へリンクする。
XDG_MIN_VERSION="3.1"
if [[ "$(printf '%s\n%s\n' "$XDG_MIN_VERSION" "$TMUX_VERSION_NUM" | sort -V | head -n1)" == "$XDG_MIN_VERSION" ]]; then
  USE_XDG=true
  log_info "~/.config/tmux/tmux.conf を使用します"
else
  USE_XDG=false
  log_warning "tmux $TMUX_VERSION は ~/.config/tmux を読まない可能性があるため ~/.tmux.conf を使用します"
fi

log_section "tmux 設定のシンボリックリンク作成"

# 既存の ~/.tmux.conf の退避
# XDG 側を使う場合、~/.tmux.conf が残っていると「編集しても効かない」混乱のもとになるため退避する。
if [[ -e ~/.tmux.conf ]] || [[ -L ~/.tmux.conf ]]; then
  if [[ "$USE_XDG" == true ]] || [[ ! -L ~/.tmux.conf ]]; then
    backup_name=~/.tmux.conf.backup.$(date +%Y%m%d_%H%M%S)
    log_warning "~/.tmux.conf が既に存在します。バックアップを作成します: $backup_name"
    mv ~/.tmux.conf "$backup_name"
  fi
fi

if [[ "$USE_XDG" == true ]]; then
  # ~/.config ディレクトリの確認・作成
  if [[ ! -d ~/.config ]]; then
    log_info "~/.config ディレクトリを作成しています..."
    mkdir -p ~/.config
    log_success "~/.config ディレクトリを作成しました"
  fi

  # .config/tmux のリンク作成
  log_info "~/.config/tmux のシンボリックリンクを作成しています..."
  if [[ -e ~/.config/tmux ]] && [[ ! -L ~/.config/tmux ]]; then
    backup_name=~/.config/tmux.backup.$(date +%Y%m%d_%H%M%S)
    log_warning "~/.config/tmux が既に存在します。バックアップを作成します: $backup_name"
    mv ~/.config/tmux "$backup_name"
  fi
  ln -sfn "$DOTFILES_DIR/.config/tmux" ~/.config/tmux
  log_success "~/.config/tmux のリンクを作成しました"
  LINK_PATH=~/.config/tmux
else
  log_info "~/.tmux.conf のシンボリックリンクを作成しています..."
  ln -sfn "$DOTFILES_DIR/.config/tmux/tmux.conf" ~/.tmux.conf
  log_success "~/.tmux.conf のリンクを作成しました"
  LINK_PATH=~/.tmux.conf
fi

log_section "設定の検証"

if [[ -L "$LINK_PATH" ]]; then
  log_success "tmux設定のリンクが正常に作成されました"
  log_info "リンク先: $(readlink "$LINK_PATH")"
else
  log_error "tmux設定のリンク作成に失敗しました"
  exit 1
fi

# 設定ファイル自体の文法確認
# 一時的なサーバを別ソケット(-L setupcheck)で起動して読み込ませる。
# 既に動いている tmux サーバやセッションには触らない。
log_info "設定ファイルの読み込みを確認しています..."
if TERM=xterm-256color tmux -L setupcheck -f "$DOTFILES_DIR/.config/tmux/tmux.conf" \
     new-session -d -s check 2>/tmp/tmux-setup-check.$$; then
  history_limit=$(TERM=xterm-256color tmux -L setupcheck show-options -gv history-limit)
  log_success "設定を読み込めました (history-limit=$history_limit)"
  tmux -L setupcheck kill-server 2>/dev/null || true
else
  log_error "設定ファイルの読み込みに失敗しました:"
  cat /tmp/tmux-setup-check.$$
  rm -f /tmp/tmux-setup-check.$$
  exit 1
fi
rm -f /tmp/tmux-setup-check.$$

# 端末の terminfo 確認
# default-terminal に指定した terminfo が無いと tmux が起動しない。
if ! infocmp tmux-256color &>/dev/null; then
  log_warning "tmux-256color の terminfo が見つかりません"
  log_info "tmux.conf の default-terminal を screen-256color に変更するか、terminfo を導入してください"
fi

# 接続元の端末（$TERM）の terminfo 確認
# 手元PCの端末が新しく、SSH 先にその terminfo が無いと attach 時に
# 「missing or unsuitable terminal」で失敗する。
if [[ -n "$TERM" ]] && ! infocmp "$TERM" &>/dev/null; then
  log_warning "この端末の terminfo ($TERM) がこのマシンにありません"
  log_info "tmux の attach に失敗します。対処は tmux-manager/README.md を参照してください"
fi

echo ""
log_section "tmux セットアップ完了"
log_success "tmux環境のセットアップが完了しました！"
echo -e "${GREEN}   ✓${NC} tmux設定ファイルがリンクされました"
echo ""
log_info "使い方は tmux-manager/README.md を参照してください。まずは以下で開始できます："
echo -e "${BLUE}   tmux new-session -A -s main${NC}"
