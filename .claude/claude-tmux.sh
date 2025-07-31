#!/bin/bash

# MIT License
#
# Copyright (c) 2025 kakei-manager contributors
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# This project includes code derived from Claude-Code-Communication by nishimoto265:
# https://github.com/nishimoto265/Claude-Code-Communication
# Original license: MIT License, Copyright (c) 2025 nishimoto265

# 🚀 Multi-Agent Communication Demo 環境構築
# 参考: setup_full_environment.sh

set -e  # エラー時に停止

# PROJECT_PREFIXを環境変数から読み取り
load_project_prefix() {
    local env_file="${BASH_SOURCE[0]%/*}/../.env"
    
    if [[ ! -f "$env_file" ]]; then
        echo "❌ エラー: .envファイルが見つかりません ($env_file)"
        echo "PROJECT_PREFIXを定義した.envファイルをプロジェクトルートに作成してください。"
        echo "例: echo 'PROJECT_PREFIX=myproject' > .env"
        exit 1
    fi
    
    # .envファイルから PROJECT_PREFIX を読み取り
    local prefix
    prefix=$(grep "^PROJECT_PREFIX=" "$env_file" | cut -d'=' -f2 | tr -d '"'"'"'')
    
    if [[ -z "$prefix" ]]; then
        echo "❌ エラー: PROJECT_PREFIXが.envファイルに定義されていません"
        echo "例: echo 'PROJECT_PREFIX=myproject' >> .env"
        exit 1
    fi
    
    echo "$prefix"
}

# プロジェクトプレフィックスを取得
PROJECT_PREFIX=$(load_project_prefix)

# ヘルプ表示
show_help() {
    echo "🤖 Multi-Agent Communication Demo 環境構築"
    echo "==========================================="
    echo ""
    echo "使用方法:"
    echo "  $0"
    echo ""
    echo "説明:"
    echo "  .envファイルからPROJECT_PREFIXを自動読み取りしてセッションを作成します"
    echo "  現在のPROJECT_PREFIX: $PROJECT_PREFIX"
    echo "  作成されるセッション: ${PROJECT_PREFIX}-multiagent, ${PROJECT_PREFIX}-president"
    echo ""
    echo "例:"
    echo "  $0              # .envのPROJECT_PREFIXを使用してセッション作成"
    echo "  $0 --help       # このヘルプを表示"
    echo ""
    exit 0
}

# 引数処理
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
fi

PREFIX="${PROJECT_PREFIX}-"

# セッション名を動的に設定
MULTIAGENT_SESSION="${PREFIX}multiagent"
PRESIDENT_SESSION="${PREFIX}president"

# 色付きログ関数
log_info() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[1;34m[SUCCESS]\033[0m $1"
}

echo "🤖 Multi-Agent Communication Demo 環境構築"
echo "   Prefix: $PROJECT_PREFIX (from .env)"
echo "==========================================="
echo ""

# STEP 1: 既存セッションクリーンアップ
log_info "🧹 既存セッションクリーンアップ開始..."

tmux kill-session -t "$MULTIAGENT_SESSION" 2>/dev/null && log_info "${MULTIAGENT_SESSION}セッション削除完了" || log_info "${MULTIAGENT_SESSION}セッションは存在しませんでした"
tmux kill-session -t "$PRESIDENT_SESSION" 2>/dev/null && log_info "${PRESIDENT_SESSION}セッション削除完了" || log_info "${PRESIDENT_SESSION}セッションは存在しませんでした"

# 完了ファイルクリア
mkdir -p ./tmp
rm -f ./tmp/worker*_done.txt 2>/dev/null && log_info "既存の完了ファイルをクリア" || log_info "完了ファイルは存在しませんでした"

log_success "✅ クリーンアップ完了"
echo ""

# STEP 2: multiagentセッション作成（4ペイン：boss1 + worker1,2,3）
log_info "📺 multiagentセッション作成開始 (4ペイン)..."

# 最初のペイン作成
tmux new-session -d -s "$MULTIAGENT_SESSION" -n "agents"

# 2x2グリッド作成（合計4ペイン）
tmux split-window -h -t "${MULTIAGENT_SESSION}:0"      # 水平分割（左右）
tmux select-pane -t "${MULTIAGENT_SESSION}:0.0"
tmux split-window -v                        # 左側を垂直分割
tmux select-pane -t "${MULTIAGENT_SESSION}:0.2"
tmux split-window -v                        # 右側を垂直分割

# ペインタイトル設定
log_info "ペインタイトル設定中..."
PANE_TITLES=("boss1" "worker1" "worker2" "worker3")

for i in {0..3}; do
    tmux select-pane -t "${MULTIAGENT_SESSION}:0.$i" -T "${PANE_TITLES[$i]}"
    
    # 作業ディレクトリ設定
    tmux send-keys -t "${MULTIAGENT_SESSION}:0.$i" "cd $(pwd)" C-m
    
    # カラープロンプト設定
    if [ $i -eq 0 ]; then
        # boss1: 赤色
        tmux send-keys -t "${MULTIAGENT_SESSION}:0.$i" "export PS1='(\[\033[1;31m\]${PANE_TITLES[$i]}\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
    else
        # workers: 青色
        tmux send-keys -t "${MULTIAGENT_SESSION}:0.$i" "export PS1='(\[\033[1;34m\]${PANE_TITLES[$i]}\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
    fi
    
    # ウェルカムメッセージ
    tmux send-keys -t "${MULTIAGENT_SESSION}:0.$i" "echo '=== ${PANE_TITLES[$i]} エージェント ==='" C-m
done

log_success "✅ multiagentセッション作成完了"
echo ""

# STEP 3: presidentセッション作成（1ペイン）
log_info "👑 presidentセッション作成開始..."

tmux new-session -d -s "$PRESIDENT_SESSION"
tmux send-keys -t "$PRESIDENT_SESSION" "cd $(pwd)" C-m
tmux send-keys -t "$PRESIDENT_SESSION" "export PS1='(\[\033[1;35m\]PRESIDENT\[\033[0m\]) \[\033[1;32m\]\w\[\033[0m\]\$ '" C-m
tmux send-keys -t "$PRESIDENT_SESSION" "echo '=== PRESIDENT セッション ==='" C-m
tmux send-keys -t "$PRESIDENT_SESSION" "echo 'プロジェクト統括責任者'" C-m
tmux send-keys -t "$PRESIDENT_SESSION" "echo '========================'" C-m

log_success "✅ presidentセッション作成完了"
echo ""

# STEP 4: 環境確認・表示
log_info "🔍 環境確認中..."

echo ""
echo "📊 セットアップ結果:"
echo "==================="

# tmuxセッション確認
echo "📺 Tmux Sessions:"
tmux list-sessions
echo ""

# ペイン構成表示
echo "📋 ペイン構成:"
echo "  multiagentセッション（4ペイン）:"
echo "    Pane 0: boss1     (チームリーダー)"
echo "    Pane 1: worker1   (実行担当者A)"
echo "    Pane 2: worker2   (実行担当者B)"
echo "    Pane 3: worker3   (実行担当者C)"
echo ""
echo "  presidentセッション（1ペイン）:"
echo "    Pane 0: PRESIDENT (プロジェクト統括)"

echo ""
log_success "🎉 Demo環境セットアップ完了！"
echo ""
echo "📋 次のステップ:"
echo "  1. 🔗 セッションアタッチ:"
echo "     tmux attach-session -t ${MULTIAGENT_SESSION}   # マルチエージェント確認"
echo "     tmux attach-session -t ${PRESIDENT_SESSION}    # プレジデント確認"
echo ""
echo "  2. 🤖 Claude Code起動:"
echo "     # 手順1: President認証"
echo "     tmux send-keys -t ${PRESIDENT_SESSION} 'claude' C-m"
echo "     # 手順2: 認証後、Presidentに対してmultiagent一括起動を指示させる"
echo "     for i in {0..3}; do tmux send-keys -t ${MULTIAGENT_SESSION}:0.\$i 'claude' C-m; done"
echo ""
echo "  3. 🎯 デモ実行: presidentに以下を入力:(うまくいけばpresidentまで帰ってきます。)"
echo "     「あなたはpresidentです。boss1に対してすべてのワーカーにIT関係のトレンドニュースを1件収集を行う指示を依頼してください。"
echo "     各ワーカーは収集したニュースをboss1へ報告してください。"
echo "     boss1は各ワーカーから報告を受けたニュースの内容で優れたニュースを1件を選定してpresidentに報告してください。」"