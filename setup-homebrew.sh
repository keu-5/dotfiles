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

echo -e "${CYAN}🍺 Homebrew セットアップを開始します${NC}"

# スクリプト自体の実行権限を確認
if [[ ! -x "$0" ]]; then
  log_error "このスクリプトに実行権限がありません。"
  log_info "実行権限を付与してから再実行してください: chmod +x setup-homebrew.sh"
  exit 1
fi

log_section "Homebrew インストール確認"
if ! command -v brew &>/dev/null; then
  log_warning "Homebrew がインストールされていません。"
  log_info "Homebrew をインストールしています..."
  
  # Homebrew のインストール
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Apple Silicon Mac の場合、PATHを設定
  if [[ $(uname -m) == "arm64" ]]; then
    log_info "Apple Silicon Mac用のPATH設定を追加しています..."
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  
  # Intel Mac の場合のPATH設定
  if [[ $(uname -m) == "x86_64" ]]; then
    log_info "Intel Mac用のPATH設定を確認しています..."
    if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
      export PATH="/usr/local/bin:$PATH"
    fi
  fi
  
  # インストール確認
  if command -v brew &>/dev/null; then
    log_success "Homebrew のインストールが完了しました"
  else
    log_error "Homebrew のインストールに失敗しました"
    log_info "手動でインストールしてください: https://brew.sh"
    exit 1
  fi
else
  log_success "Homebrew は既にインストールされています"
fi

log_section "Homebrew の更新"
log_info "Homebrew を最新版に更新しています..."
if brew update >/dev/null 2>&1; then
  log_success "Homebrew の更新が完了しました"
else
  log_warning "Homebrew の更新でエラーが発生しましたが、続行します"
fi

log_section "必須ツールのインストール"
log_info "開発に必要なツールをインストールしています..."

# 基本ツール
tools_to_install=(
  "zsh-autosuggestions"
  "zsh-completions" 
  "python@3.13"
  "nodebrew"
  "neovim"
  "git"
)

for tool in "${tools_to_install[@]}"; do
  log_info "$tool をインストール中..."
  if brew install "$tool" >/dev/null 2>&1; then
    log_success "$tool をインストールしました"
  else
    log_warning "$tool のインストールでエラーが発生しました（既にインストール済みの可能性があります）"
  fi
done

log_section "フォントのインストール"
log_info "開発用フォントをインストールしています..."

fonts_to_install=(
  "font-hack-nerd-font"
  "font-fira-code"
)

for font in "${fonts_to_install[@]}"; do
  log_info "$font をインストール中..."
  if brew install --cask "$font" >/dev/null 2>&1; then
    log_success "$font をインストールしました"
  else
    log_warning "$font のインストールでエラーが発生しました（既にインストール済みの可能性があります）"
  fi
done

log_section "追加の開発ツール（オプション）"
log_info "追加の開発ツールをインストールしています..."

optional_tools=(
  "tree"
  "wget"
  "curl"
  "jq"
  "ripgrep"
  "fd"
  "bat"
  "exa"
)

for tool in "${optional_tools[@]}"; do
  log_info "$tool をインストール中..."
  if brew install "$tool" >/dev/null 2>&1; then
    log_success "$tool をインストールしました"
  else
    log_warning "$tool のインストールでエラーが発生しました"
  fi
done

log_section "Homebrew セットアップ完了"
echo -e "${CYAN}🎉 Homebrew セットアップが完了しました！${NC}"
echo ""
echo -e "${GREEN}📦 インストールされたツール：${NC}"
echo -e "${BLUE}   基本ツール：${NC} zsh-autosuggestions, zsh-completions, python@3.13, nodebrew, neovim, git"
echo -e "${BLUE}   フォント：${NC} Hack Nerd Font, Fira Code"
echo -e "${BLUE}   追加ツール：${NC} tree, wget, curl, jq, ripgrep, fd, bat, exa"
echo ""
echo -e "${GREEN}💡 次のステップ：${NC}"
echo -e "${BLUE}   ./install.sh${NC} - 基本的な開発環境のセットアップ"
echo -e "${BLUE}   ./setup-latex.sh${NC} - LaTeX環境のセットアップ（必要に応じて）"
