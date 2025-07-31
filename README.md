# CLAUDE TMUX
claude code向けのtmuxを利用したバイブコーディングサンプル

## 前提
* [Claude-Code-Communication](https://github.com/nishimoto265/Claude-Code-Communication)を編集して作成を行っています。

## エージェント構成
```
📊 PRESIDENT セッション (1ペイン)
└── PRESIDENT: プロジェクト統括責任者

📊 multiagent セッション (4ペイン)  
├── boss1: チームリーダー
├── worker1: 実行担当者A
├── worker2: 実行担当者B
└── worker3: 実行担当者C
```

## 使い方
他のプロジェクトで利用する場合は「.claude/agent-send.sh」「.claude/claude-tmux.sh」をコピーしenvを設定すれば動きます。  

### 1. envの設定
.env-sampleをコピーし.envを作成  
PROJECT_PREFIXを任意の名前に変更してください。  
※ここの命名が被るとtmuxのセッションが競合を起こした場合、古いセッションが破棄させます。

### 2. tmux環境構築
プロジェクトルートで以下のコマンドを実行しtmuxの環境構築を行う
```shall
./.claude/claude-tmux.sh
```

### 3. セッションアタッチ
2.の処理結果に以下のようなログが出るのでコピーし各々別のターミナルで実行
```shell
# マルチエージェント確認
tmux attach-session -t xxx-multiagent

# プレジデント確認（別ターミナルで）
tmux attach-session -t xxx-president
```

### 4. Claude Code起動
#### 手順1: President認証
2.の処理結果に以下のようなログが出るのでコピーしpresidentのセッションターミナルで実行
```shell
# まずPRESIDENTで認証を実施
tmux send-keys -t president 'claude' C-m
```

#### 手順2: Multiagent一括起動
2.の処理結果に以下のようなログが出るのでコピーしpresidentのclaude codeに対して実行
```shell
# 認証完了後、multiagentセッションを一括起動
for i in {0..3}; do tmux send-keys -t multiagent:0.$i 'claude' C-m; done
```