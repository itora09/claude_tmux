### 1. 画面概要
- **目的**: この画面の機能を一言で表現（例：「プロジェクトの検索・詳細表示機能」）
- **主要機能**: 3〜5点で機能を列挙
- **対象ユーザー**: 想定利用者の説明
- **画面の位置づけ**: システム全体での役割

### 2. 画面レイアウト
- **レイアウト図**: 画面モック、ワイヤーフレーム、またはASCII図
- **画面サイズ**: デスクトップ/タブレット/モバイル対応
- **主要エリア**: ヘッダー、コンテンツ、フッターなどの配置

### 3. 一覧表示
- **表示対象**: 何のデータを一覧表示するか
- **表示件数**: ページネーション設定
- **ソート機能**: 並び替え項目と順序
- **フィルタ機能**: 検索・絞り込み条件

### 4. 画面項目定義
| 項目名 | 種別 | 必須 | 最大長 | 形式 | 初期値 | 備考 |
|--------|------|------|--------|------|--------|------|
| | 入力/出力/表示 | ○/- | | | | |

### 5. 入出力一覧
| 処理 | 対象 | テーブル/ファイル名 | 操作種別 | 備考 |
|------|------|-------------------|----------|------|
| | 入力/出力 | | 参照/更新/追加/削除 | |

### 6. 画面イベント一覧
| イベント名 | 発生タイミング | 処理内容 | 画面遷移 | サーバ通信 |
|------------|----------------|----------|----------|------------|
| | | | 有/無 | 有/無 |

### 7. 画面イベント詳細
各イベントについて以下を記載：
- **入力チェック（バリデーション）**: 必須チェック、形式チェック、業務ロジックチェック
- **画面表示制御**: 項目の表示/非表示、活性/非活性制御
- **テーブル操作**: CRUD操作の詳細
- **画面遷移**: 遷移先画面と遷移条件
- **エラーハンドリング**: エラーメッセージとユーザー向け案内

### 8. 〇〇
必要になったら8章以降は適宜追加