## claude Code
claude codeは基本的に日本語でやり取りを行う

## tmux
### エージェント構成
* president (別セッション): 統括責任者
* boss1 (multiagent:agents): チームリーダー
* worker1,2,3 (multiagent:agents): 実行担当

### エージェント間のメッセージ送信
./.claude/agent-send.sh [相手] "[メッセージ]"

## document
path：./document配下すべて
### 設計書
* 要求定義書：001_要求定義.md
* 要件定義書：002_要件定義.md
* 基本設計書：003_基本設計.md