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

echo -e "${CYAN}🔍 Dotfiles 環境検証を開始します${NC}"

log_section "ディレクトリ構造の確認"

# 必要なディレクトリの存在確認
directories=(
    ".config/nvim"
    "homebrew" 
    "latex"
    "vscode-manager"
)

for dir in "${directories[@]}"; do
    if [[ -d "$DOTFILES_DIR/$dir" ]]; then
        log_success "✓ $dir ディレクトリが存在します"
    else
        log_error "✗ $dir ディレクトリが見つかりません"
    fi
done

log_section "重要なファイルの確認"

# 必要なファイルの存在確認
files=(
    "install.sh"
    "homebrew/setup.sh"
    "homebrew/Brewfile"
    "latex/setup-latex.sh"
    "vscode-manager/setup-vscode.sh"
    "vscode-manager/settings.json"
    "vscode-manager/extensions.txt"
    ".zshrc"
    ".config/nvim/init.lua"
)

for file in "${files[@]}"; do
    if [[ -f "$DOTFILES_DIR/$file" ]]; then
        log_success "✓ $file が存在します"
    else
        log_error "✗ $file が見つかりません"
    fi
done

log_section "実行権限の確認"

# 実行可能スクリプトの権限確認
scripts=(
    "install.sh"
    "homebrew/setup.sh"
    "latex/setup-latex.sh"
    "vscode-manager/setup-vscode.sh"
)

for script in "${scripts[@]}"; do
    if [[ -x "$DOTFILES_DIR/$script" ]]; then
        log_success "✓ $script に実行権限があります"
    else
        log_warning "⚠ $script に実行権限がありません"
        log_info "修正コマンド: chmod +x $script"
    fi
done

log_section "シンボリックリンクの確認"

# ホームディレクトリのシンボリックリンク確認
links=(
    "$HOME/.config/nvim:$DOTFILES_DIR/.config/nvim"
    "$HOME/.zshrc:$DOTFILES_DIR/.zshrc"
)

for link_pair in "${links[@]}"; do
    IFS=':' read -r link_path target_path <<< "$link_pair"
    
    if [[ -L "$link_path" ]]; then
        actual_target=$(readlink "$link_path")
        if [[ "$actual_target" == "$target_path" ]]; then
            log_success "✓ $link_path → $target_path"
        else
            log_warning "⚠ $link_path → $actual_target (期待値: $target_path)"
        fi
    elif [[ -e "$link_path" ]]; then
        log_warning "⚠ $link_path は存在しますがシンボリックリンクではありません"
    else
        log_info "○ $link_path は未設定です（install.sh実行後に作成されます）"
    fi
done

log_section "VS Code設定の確認"

VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
vscode_links=(
    "$VSCODE_USER_DIR/settings.json:$DOTFILES_DIR/vscode-manager/settings.json"
    "$VSCODE_USER_DIR/keybindings.json:$DOTFILES_DIR/vscode-manager/keybindings.json"
    "$VSCODE_USER_DIR/snippets:$DOTFILES_DIR/vscode-manager/snippets"
)

for link_pair in "${vscode_links[@]}"; do
    IFS=':' read -r link_path target_path <<< "$link_pair"
    
    if [[ -L "$link_path" ]]; then
        actual_target=$(readlink "$link_path")
        if [[ "$actual_target" == "$target_path" ]]; then
            log_success "✓ VS Code: $(basename "$link_path") → vscode-manager/"
        else
            log_warning "⚠ VS Code: $(basename "$link_path") → $actual_target"
        fi
    elif [[ -e "$link_path" ]]; then
        log_warning "⚠ VS Code: $(basename "$link_path") は存在しますがシンボリックリンクではありません"
    else
        log_info "○ VS Code: $(basename "$link_path") は未設定です"
    fi
done

log_section "依存関係の確認"

# 必要なコマンドの存在確認
commands=(
    "brew:Homebrew"
    "git:Git"
    "zsh:Z Shell"
)

for cmd_pair in "${commands[@]}"; do
    IFS=':' read -r cmd desc <<< "$cmd_pair"
    
    if command -v "$cmd" &>/dev/null; then
        version=$(eval "$cmd --version 2>/dev/null | head -1" || echo "不明")
        log_success "✓ $desc が利用可能です ($version)"
    else
        log_warning "⚠ $desc が見つかりません"
    fi
done

echo ""
log_section "検証完了"
echo -e "${CYAN}🎉 Dotfiles 環境の検証が完了しました！${NC}"
echo ""
echo -e "${GREEN}📚 次のステップ：${NC}"
echo -e "${BLUE}   ./install.sh${NC}                     # 基本環境のセットアップ"
echo -e "${BLUE}   ./vscode-manager/setup-vscode.sh${NC} # VS Code環境のセットアップ"
echo -e "${BLUE}   ./latex/setup-latex.sh${NC}           # LaTeX環境のセットアップ"
