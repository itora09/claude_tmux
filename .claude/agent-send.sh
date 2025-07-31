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

# 🚀 Agent間メッセージ送信スクリプト

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

# tmuxのbase-indexとpane-base-indexを動的に取得
get_tmux_indices() {
    local session="$1"
    local window_index=$(tmux show-options -t "$session" -g base-index 2>/dev/null | awk '{print $2}')
    local pane_index=$(tmux show-options -t "$session" -g pane-base-index 2>/dev/null | awk '{print $2}')

    # デフォルト値
    window_index=${window_index:-0}
    pane_index=${pane_index:-0}

    echo "$window_index $pane_index"
}

# エージェント→tmuxターゲット マッピング
get_agent_target() {
    case "$1" in
        "president") echo "${PROJECT_PREFIX}-president" ;;
        "boss1"|"worker1"|"worker2"|"worker3")
            # multiagentセッションのindexを動的に取得
            if tmux has-session -t "${PROJECT_PREFIX}-multiagent" 2>/dev/null; then
                local indices=($(get_tmux_indices "${PROJECT_PREFIX}-multiagent"))
                local window_index=${indices[0]}
                local pane_index=${indices[1]}

                # window名で取得（base-indexに依存しない）
                local window_name="agents"

                # pane番号を計算
                case "$1" in
                    "boss1") echo "${PROJECT_PREFIX}-multiagent:$window_name.$((pane_index))" ;;
                    "worker1") echo "${PROJECT_PREFIX}-multiagent:$window_name.$((pane_index + 1))" ;;
                    "worker2") echo "${PROJECT_PREFIX}-multiagent:$window_name.$((pane_index + 2))" ;;
                    "worker3") echo "${PROJECT_PREFIX}-multiagent:$window_name.$((pane_index + 3))" ;;
                esac
            else
                echo ""
            fi
            ;;
        *) echo "" ;;
    esac
}

show_usage() {
    cat << EOF
🤖 Agent間メッセージ送信

使用方法:
  $0 [エージェント名] [メッセージ]
  $0 --list

利用可能エージェント:
  president - プロジェクト統括責任者
  boss1     - チームリーダー  
  worker1   - 実行担当者A
  worker2   - 実行担当者B
  worker3   - 実行担当者C

使用例:
  $0 president "指示書に従って"
  $0 boss1 "Hello World プロジェクト開始指示"
  $0 worker1 "作業完了しました"
EOF
}

# エージェント一覧表示
show_agents() {
    echo "📋 利用可能なエージェント:"
    echo "=========================="

    # presidentセッション確認
    if tmux has-session -t "${PROJECT_PREFIX}-president" 2>/dev/null; then
        echo "  president → ${PROJECT_PREFIX}-president       (プロジェクト統括責任者)"
    else
        echo "  president → [未起動]        (プロジェクト統括責任者)"
    fi

    # multiagentセッション確認
    if tmux has-session -t "${PROJECT_PREFIX}-multiagent" 2>/dev/null; then
        local boss1_target=$(get_agent_target "boss1")
        local worker1_target=$(get_agent_target "worker1")
        local worker2_target=$(get_agent_target "worker2")
        local worker3_target=$(get_agent_target "worker3")

        echo "  boss1     → ${boss1_target:-[エラー]}  (チームリーダー)"
        echo "  worker1   → ${worker1_target:-[エラー]}  (実行担当者A)"
        echo "  worker2   → ${worker2_target:-[エラー]}  (実行担当者B)"
        echo "  worker3   → ${worker3_target:-[エラー]}  (実行担当者C)"
    else
        echo "  boss1     → [未起動]        (チームリーダー)"
        echo "  worker1   → [未起動]        (実行担当者A)"
        echo "  worker2   → [未起動]        (実行担当者B)"
        echo "  worker3   → [未起動]        (実行担当者C)"
    fi
}

# ログ記録
log_send() {
    local agent="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    mkdir -p logs
    echo "[$timestamp] $agent: SENT - \"$message\"" >> logs/send_log.txt
}

# メッセージ送信
send_message() {
    local target="$1"
    local message="$2"
    
    echo "📤 送信中: $target ← '$message'"
    
    # Claude Codeのプロンプトを一度クリア
    tmux send-keys -t "$target" C-c
    sleep 0.3
    
    # メッセージ送信
    tmux send-keys -t "$target" "$message"
    sleep 0.1
    
    # エンター2回押下（省略表示対策）
    tmux send-keys -t "$target" C-m
    sleep 0.3
    tmux send-keys -t "$target" C-m
    sleep 0.5
}

# ターゲット存在確認
check_target() {
    local target="$1"
    local session_name="${target%%:*}"
    
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        echo "❌ セッション '$session_name' が見つかりません"
        return 1
    fi
    
    return 0
}

# メイン処理
main() {
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 1
    fi
    
    # --listオプション
    if [[ "$1" == "--list" ]]; then
        show_agents
        exit 0
    fi
    
    if [[ $# -lt 2 ]]; then
        show_usage
        exit 1
    fi
    
    local agent_name="$1"
    local message="$2"
    
    # エージェントターゲット取得
    local target
    target=$(get_agent_target "$agent_name")
    
    if [[ -z "$target" ]]; then
        echo "❌ エラー: 不明なエージェント '$agent_name'"
        echo "利用可能エージェント: $0 --list"
        exit 1
    fi
    
    # ターゲット確認
    if ! check_target "$target"; then
        exit 1
    fi
    
    # メッセージ送信
    send_message "$target" "$message"
    
    # ログ記録
    log_send "$agent_name" "$message"
    
    echo "✅ 送信完了: $agent_name に '$message'"
    
    return 0
}

main "$@" 