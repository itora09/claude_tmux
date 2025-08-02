# 画面仕様書作成コマンド

あなたはプロのWeb開発ディレクターです。既存の設計書を基に、指定された画面の詳細仕様書を作成してください。

## 前提条件
- 参照ドキュメント：`./document/001_要求定義.md`、`./document/002_要件定義.md`、`./document/003_基本設計.md`
- 出力先：`./document/004_画面仕様/{画面名}.md`
- 計画ファイル保存先：`./.claude/plan/`

## 実行手順

### 1. 事前確認
1. **設計書の確認**
   - Read toolを使用して上記3つの設計書を読み込み
   - 画面一覧と各画面の概要を把握

2. **対象画面のヒアリング**
   - 設計書の内容を基に、どの画面の仕様書を作成するか確認
   - 画面名と主要機能を明確化

### 2. 作業方式の選択
**ユーザーに以下を確認：**
- 単一エージェント（高速、シンプル）
- 複数エージェント（高精度、高コスト ※MAXプラン推奨）

### 3. 実行計画の作成

#### 単一エージェントの場合
単一エージェントの場合実装計画は不要

#### 複数エージェントの場合
**計画ファイル構成：** `./.claude/plan/yyyyMMddhhmmss-screen-spec-{画面名}/`
```
yyyyMMddhhmmss-screen-spec-{画面名}/
├── boss1.md        # boss1専用計画・指示書
├── worker1.md      # worker1専用計画・指示書
├── worker2.md      # worker2専用計画・指示書
└── worker3.md      # worker3専用計画・指示書
```

**複数エージェント作業フロー：**

1. すべてのエージェントに「/clear」コマンドを送信
2. 実装計画ファイルを作成し、各エージェント用の作業指示を準備(実装計画テンプレート参照)
3. boss1が実装計画を確認し、内容を把握して統括を行う
4. boss1が各worker（worker1, worker2, worker3）に、各worker{N}実装計画を元に作業することを指示
5. 各workerが実装計画の内容を元に各種作業を実行  
   ※手順書内にboss1に報告する手順あり
6. boss1が各workerからの報告を受けて、各workerが作成した成果物を確認
8. boss1が最終成果物を`./document/004_画面仕様/{画面名}.md`に保存
   ※手順書内にpresidentに報告する手順あり

**boss1の実装計画テンプレート**
```markdown
# boss1実装計画

## 対象画面
{画面名}

## 作業概要
各workerに画面仕様書作成を指示し、成果物を統合して最終版を作成する

## 参照資料
- `./document/001_要求定義.md`
- `./document/002_要件定義.md` 
- `./document/003_基本設計.md`

## 各workerへの指示内容
全workerに同じ指示を送信：画面仕様書の作成

## 作業手順
1. 各workerに各workerの実装計画を元に作業を行うように指示
「./.claude/yyyyMMddhhmmss-screen-spec-{画面名}/worker{N}.md」
2. 各workerからの作業報告を待機
3. 3つの成果物を比較・統合
4. 最終版として`./document/004_画面仕様/{画面名}.md`に保存  
./document/004_画面仕様/template.mdのフォーマットに沿って画面仕様書を作成

## 成果物品質基準
- 7章構成の完全性
- 項目定義の網羅性
- 技術的整合性
```

**workerの実装計画テンプレート**
```markdown
# worker{N}実装計画

## 対象画面
{画面名}

## 作業方針
全worker共通：7章構成による包括的な画面仕様書の作成

## 参照資料
- `./document/001_要求定義.md`
- `./document/002_要件定義.md`
- `./document/003_基本設計.md`

## 作業内容
./document/004_画面仕様/template.mdのフォーマットに沿って画面仕様書を作成

## 出力先
`./.claude/tmp/worker{N}/yyyyMMddhhmmss-{画面名}-spec/{画面名}-screen-spec.md`

## 【必須】完了報告
```
./.claude/agent-send.sh boss1 "【worker{N}】{画面名}仕様書作成完了。ファイルパス: ./.claude/tmp/worker{N}/yyyyMMddhhmmss-{画面名}-spec/{画面名}-screen-spec.md"
```
```

### 4. 作業実行
**実行計画承認後：**

#### 単一エージェントの場合
- TodoWrite toolで作業項目管理
- ./document/004_画面仕様/template.mdのフォーマットに沿って画面仕様書を作成

#### 複数エージェントの場合
- ./.claude/agent-send.sh使用でboss1に計画ファイルパスを共有し作業依頼
- boss1からの報告まで待機
- レビュー・承認プロセス実行
