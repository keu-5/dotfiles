#!/bin/bash
# このリポの検証契約。exit 0 = 合格。
# dotfiles はビルドもテストもないので、検証は「壊れた設定を配らない」ことに絞る。
#   1. シェルスクリプトの構文チェック（bash -n）
#   2. tmux 設定が実際に読み込めるか（使い捨てソケットの一時サーバで確認）
#   3. validate.sh の完走
set -u

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
status=0

echo "==== シェルスクリプトの構文チェック ===="
while IFS= read -r script; do
    if bash -n "$script" 2>/tmp/verify-syntax.$$; then
        echo "  ok   $(basename "$script")"
    else
        echo "  NG   $script"
        cat /tmp/verify-syntax.$$
        status=1
    fi
done < <(find "$DOTFILES_DIR" -path "$DOTFILES_DIR/.git" -prune -o -name '*.sh' -type f -print | sort)
rm -f /tmp/verify-syntax.$$

echo "==== tmux 設定の読み込み確認 ===="
if command -v tmux &>/dev/null; then
    socket="verify$$"
    if TERM=xterm-256color tmux -L "$socket" -f "$DOTFILES_DIR/.config/tmux/tmux.conf" \
         new-session -d -s verify 2>/tmp/verify-tmux.$$; then
        echo "  ok   .config/tmux/tmux.conf を読み込めた"
        tmux -L "$socket" kill-server 2>/dev/null || true
        rm -f "/tmp/tmux-$(id -u)/$socket"
    else
        echo "  NG   .config/tmux/tmux.conf の読み込みに失敗"
        cat /tmp/verify-tmux.$$
        status=1
    fi
    rm -f /tmp/verify-tmux.$$
else
    echo "  skip tmux が未インストール"
fi

echo "==== validate.sh ===="
if bash "$DOTFILES_DIR/validate.sh" >/tmp/verify-validate.$$ 2>&1; then
    # validate.sh は結果を報告するだけで exit code を落とさないため、
    # [ERROR] 行の有無で合否を判定する。
    if grep -q '\[ERROR\]' /tmp/verify-validate.$$; then
        echo "  NG   validate.sh がエラーを報告した"
        grep '\[ERROR\]' /tmp/verify-validate.$$
        status=1
    else
        echo "  ok   validate.sh にエラーなし"
    fi
else
    echo "  NG   validate.sh が異常終了した"
    cat /tmp/verify-validate.$$
    status=1
fi
rm -f /tmp/verify-validate.$$

echo
if [[ $status -eq 0 ]]; then
    echo "VERIFY: PASS"
else
    echo "VERIFY: FAIL"
fi
exit $status
