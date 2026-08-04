#!/bin/bash
set -e

# 手元PCの端末の terminfo を SSH 先へ送り込むスクリプト。
#
# 目的:
#   Ghostty のような新しい端末は TERM=xterm-ghostty を名乗るが、SSH 先の ncurses が古いと
#   その記述を持っていない（Ubuntu 22.04 の ncurses 6.3 は 2021 年のもので、ghostty を含まない）。
#   TERM だけが渡って記述が無い状態になるため、tmux が
#   "missing or unsuitable terminal: xterm-ghostty" で起動できない。
#   手元にある記述をそのまま送って SSH 先の ~/.terminfo に置けば解決する。
#
# 実行場所:
#   ★ SSH 先ではなく「手元PC」で実行する。送る記述は手元の端末が持っているものだから。
#
# 根拠:
#   Ghostty 公式ドキュメント (https://ghostty.org/docs/help/terminfo) が案内する
#   `infocmp -x xterm-ghostty | ssh YOUR-SERVER -- tic -x -` と同じことをする。
#   このスクリプトは加えて、書き込み先を ~/.terminfo に固定し、転送後に SSH 先で
#   実際に引けるかを検証する。

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

usage() {
    cat <<'EOS'
使い方: ./tmux-manager/push-terminfo.sh [--term TERM名] <SSH先> [SSH先...]

  <SSH先>       ssh に渡すのと同じ指定（~/.ssh/config のホスト名、user@host など）
  --term TERM名 送る terminfo を明示する（既定は現在の $TERM）

例:
  ./tmux-manager/push-terminfo.sh rtx4070ti
  ./tmux-manager/push-terminfo.sh --term xterm-ghostty kafe.marute@172.28.18.82

★ このスクリプトは SSH 先ではなく「手元PC」で実行する。
EOS
}

term="${TERM:-}"
term_explicit=false
hosts=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --term)
      if [[ -z "${2:-}" ]]; then
        log_error "--term に値がありません"
        usage
        exit 1
      fi
      term="$2"
      term_explicit=true
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      log_error "不明なオプション: $1"
      usage
      exit 1
      ;;
    *)
      hosts+=("$1")
      shift
      ;;
  esac
done

if [[ ${#hosts[@]} -eq 0 ]]; then
  log_error "SSH 先が指定されていません"
  usage
  exit 1
fi

echo -e "${CYAN}🚀 terminfo の転送を開始します${NC}"

log_section "手元側の確認"

# SSH 先で実行してしまう事故を防ぐ。
# このスクリプトが送るのは「手元の端末の記述」なので、SSH 先で走らせても意味がない
# （SSH 先には送るべき記述が無いから、そもそも下の infocmp で落ちる）。
if [[ -n "${SSH_CONNECTION:-}" ]]; then
  log_warning "SSH 接続中のマシンで実行しています。このスクリプトは手元PCで実行するものです"
fi

# tmux の中では $TERM は tmux 自身のもの（tmux-256color など）になり、
# 外側の端末（Ghostty）の TERM ではない。既定値のまま送ると意図と違うものが飛ぶ。
if [[ -n "${TMUX:-}" ]] && [[ "$term_explicit" == false ]]; then
  log_warning "tmux の中で実行しています。\$TERM ($term) は tmux 自身のもので、外側の端末のものではありません"
  log_info "外側の端末の記述を送りたい場合は --term で明示してください（例: --term xterm-ghostty）"
fi

if ! command -v infocmp &>/dev/null; then
  log_error "infocmp が見つかりません（ncurses が必要です）"
  exit 1
fi

# terminfo 名はこのあと SSH 先へ渡すコマンド文字列に埋め込むため、
# シェルのメタ文字が混ざらないことを確認しておく。
if [[ ! "$term" =~ ^[A-Za-z0-9._+-]+$ ]]; then
  log_error "terminfo 名として扱えない文字列です: '$term'"
  exit 1
fi

if ! infocmp -x "$term" >/dev/null 2>&1; then
  log_error "手元に '$term' の terminfo がありません。送るものがないので中止します"
  log_info "端末側で TERM が正しいか、端末が terminfo を導入済みか確認してください"
  exit 1
fi
log_success "手元の terminfo を確認しました ($term)"

log_section "SSH 先への転送"

# SSH 先で実行する処理。
#   1. ~/.terminfo を作る
#   2. TERMINFO を指定して tic に書かせる
#   3. TERMINFO を外した状態で引けるか確認する
#
# TERMINFO を指定するのは書き込み先を確定させるため。tic は既定ではシステムの
# terminfo データベースへ書こうとし、権限が無い場合にのみ ~/.terminfo へ回る（tic(1) の記述）。
# 明示すれば root 権限の有無で挙動が変わらない。
# 検証の infocmp では TERMINFO を渡さない。ncurses は既定で $HOME/.terminfo を探索するので、
# 「環境変数の助けなしに引けること」まで確かめられる。
remote_cmd="mkdir -p \"\$HOME/.terminfo\" && TERMINFO=\"\$HOME/.terminfo\" tic -x - && infocmp -x $term > /dev/null"

failed=()
for host in "${hosts[@]}"; do
  log_info "$host へ '$term' を送っています..."

  # テンプレートを明示する。macOS の BSD 版 mktemp は引数なしの呼び出しを受け付けない。
  errfile=$(mktemp "${TMPDIR:-/tmp}/push-terminfo.XXXXXX")
  if infocmp -x "$term" 2>"$errfile" | ssh "$host" "$remote_cmd" 2>>"$errfile"; then
    log_success "$host: 転送し、SSH 先で引けることを確認しました"
    # tic は互換性の注意を stderr に出すが、終了コードは 0 で実害はない。
    # 例: "older tic versions may treat the description field as an alias"
    #     （記述の最終フィールドを古い tic がエイリアスと誤解しうる、という注意）
    # 検証まで通った以上は無害なので、そう明示して見せる。
    if [[ -s "$errfile" ]]; then
      log_info "$host: tic からの警告（無害。検証は通っています）:"
      sed 's/^/    /' "$errfile"
    fi
  else
    log_error "$host: 転送または検証に失敗しました"
    [[ -s "$errfile" ]] && sed 's/^/    /' "$errfile"
    failed+=("$host")
  fi
  rm -f "$errfile"
done

log_section "結果"

if [[ ${#failed[@]} -eq 0 ]]; then
  log_success "すべての SSH 先で '$term' が使えるようになりました"
  echo ""
  log_info "SSH 先では TERM を変えずにそのまま起動できます："
  echo -e "${BLUE}   tmux new-session -A -s main${NC}"
  exit 0
else
  log_error "失敗した SSH 先: ${failed[*]}"
  echo ""
  log_info "その場しのぎとして、SSH 先で次のようにすれば tmux は起動できます："
  echo -e "${YELLOW}   TERM=xterm-256color tmux new-session -A -s main${NC}"
  log_info "ただし colored/styled underline など xterm を超える機能は使えません"
  exit 1
fi
