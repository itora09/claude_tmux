
## tmuxについて
### エージェント構成
* PRESIDENT (別セッション): 統括責任者
* boss1 (multiagent:agents): チームリーダー
* worker1,2,3 (multiagent:agents): 実行担当

### エージェント間のメッセージ送信
./.claude/agent-send.sh [相手] "[メッセージ]"