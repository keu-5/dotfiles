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
VSCODE_MANAGER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$VSCODE_MANAGER_DIR")"

echo -e "${CYAN}🚀 VS Code 環境セットアップを開始します${NC}"

# スクリプト自体の実行権限を確認
if [[ ! -x "$0" ]]; then
  log_error "このスクリプトに実行権限がありません。"
  log_info "実行権限を付与してから再実行してください: chmod +x setup-vscode.sh"
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

log_section "VS Code インストール確認"
# VS Code の確認（Homebrewでインストールされていない場合のみインストール）
if ! command -v code &>/dev/null; then
  log_warning "VS Code が見つかりません。Homebrew経由でインストールします..."
  brew install --cask visual-studio-code
  
  # VS Code の code コマンドを PATH に追加
  log_info "VS Code コマンドラインツールをセットアップしています..."
  if [[ ":$PATH:" != *":/Applications/Visual Studio Code.app/Contents/Resources/app/bin:"* ]]; then
    export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
  fi
  
  # VS Code が正常にインストールされたか確認
  if ! command -v code &>/dev/null; then
    log_warning "VS Code コマンドラインツールの手動セットアップが必要な可能性があります。"
    log_info "確認してください: 'code --version'"
  else
    log_success "VS Code のインストールが完了しました"
  fi
else
  log_success "VS Code は既にインストールされています"
fi

log_section "VS Code 拡張機能のインストール"
# 拡張機能をインストール
if [[ -f "$VSCODE_MANAGER_DIR/extensions.txt" ]]; then
    log_info "拡張機能リストから拡張機能をインストールしています..."
    while IFS= read -r extension; do
        # 空行やコメント行をスキップ
        [[ -z "$extension" || "$extension" =~ ^[[:space:]]*# ]] && continue
        
        log_info "拡張機能をインストール中: $extension"
        if code --install-extension "$extension" --force >/dev/null 2>&1; then
            log_success "✓ $extension"
        else
            log_warning "⚠ $extension のインストールに失敗しました"
        fi
    done < "$VSCODE_MANAGER_DIR/extensions.txt"
    log_success "拡張機能のインストールが完了しました"
else
    log_warning "extensions.txt が見つかりません"
fi

log_section "VS Code 設定ファイルのリンク"
VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"

# VS Code設定ディレクトリを適切な権限で作成
log_info "VS Code 設定ディレクトリを作成しています..."
mkdir -p "$VSCODE_USER_DIR"
chmod 755 "$VSCODE_USER_DIR"
log_success "VS Code 設定ディレクトリを作成しました"

# 既存のsettings.jsonを削除してからリンクを作成
log_info "settings.json のリンクを作成しています..."
if [ -f "$VSCODE_USER_DIR/settings.json" ] || [ -L "$VSCODE_USER_DIR/settings.json" ]; then
  log_warning "既存の settings.json を削除しています..."
  rm -f "$VSCODE_USER_DIR/settings.json"
fi
ln -sf "$VSCODE_MANAGER_DIR/settings.json" "$VSCODE_USER_DIR/settings.json"
log_success "settings.json のリンクを作成しました"

# 既存のkeybindings.jsonを削除してからリンクを作成
log_info "keybindings.json のリンクを作成しています..."
if [ -f "$VSCODE_USER_DIR/keybindings.json" ] || [ -L "$VSCODE_USER_DIR/keybindings.json" ]; then
  log_warning "既存の keybindings.json を削除しています..."
  rm -f "$VSCODE_USER_DIR/keybindings.json"
fi
ln -sf "$VSCODE_MANAGER_DIR/keybindings.json" "$VSCODE_USER_DIR/keybindings.json"
log_success "keybindings.json のリンクを作成しました"

# 既存のsnippetsディレクトリを削除してからリンクを作成
log_info "snippets ディレクトリのリンクを作成しています..."
if [ -d "$VSCODE_USER_DIR/snippets" ] || [ -L "$VSCODE_USER_DIR/snippets" ]; then
  log_warning "既存の snippets ディレクトリを削除しています..."
  rm -rf "$VSCODE_USER_DIR/snippets"
fi
ln -snf "$VSCODE_MANAGER_DIR/snippets" "$VSCODE_USER_DIR/snippets"
log_success "snippets ディレクトリのリンクを作成しました"

echo ""
log_section "セットアップ完了"
log_success "VS Code 環境のセットアップが完了しました！"
echo -e "${GREEN}   ✓${NC} VS Code の設定ファイルがリンクされました"
echo -e "${GREEN}   ✓${NC} VS Code の拡張機能がインストールされました"
echo -e "${GREEN}   ✓${NC} Neovim 統合の準備が完了しました"
echo ""
echo -e "${GREEN}🔧 設定ファイル：${NC}"
echo -e "${BLUE}   $VSCODE_USER_DIR/settings.json${NC} - VS Code設定"
echo -e "${BLUE}   $VSCODE_USER_DIR/keybindings.json${NC} - キーバインド設定"
echo -e "${BLUE}   $VSCODE_USER_DIR/snippets/${NC} - スニペット集"
echo ""
echo -e "${GREEN}📚 使用方法：${NC}"
echo -e "${BLUE}   code .${NC}                      # 現在のディレクトリを開く"
echo -e "${BLUE}   code --list-extensions${NC}      # インストール済み拡張機能一覧"
echo -e "${BLUE}   code --install-extension <id>${NC} # 拡張機能追加インストール"
