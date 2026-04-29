---
name: hestia
description: Hestia の各機能を実行する。「日記を集めて」「日記を更新」「今日の回答を取り込んで」「日記まとめて」→ 日記収集。「タスクを取り込んで」「タスクを追加して」「リマインダーに追加して」→ タスク取り込み。
---

# Hestia

ユーザーのリクエストを解釈し、日記収集またはタスク取り込みを実行する skill。

---

## 機能A: 日記収集

Discord に届いた本日分の Q&A を取り込み、`journal/YYYY-MM-DD.md` を再生成する。

### 実行手順

1. 収集スクリプトを実行する:

   ```bash
   bash .hestia/scripts/collect.sh
   ```

2. 生成されたファイルを確認:

   ```bash
   cat "journal/$(TZ=Asia/Tokyo date '+%Y-%m-%d').md"
   ```

3. ユーザーに以下を報告する:
   - 取り込まれた質問の数
   - 各質問への回答有無
   - 回答が `_(回答なし)_` の質問があれば示唆

### 注意点

- スクリプトは**冪等**。何度実行しても問題ない
- Discord API は1回で最新100件まで取得。1日分には十分
- `.hestia/config.env` に `DISCORD_BOT_TOKEN` と `DISCORD_CHANNEL_ID` が必要
- `journal/` は Obsidian Sync で同期されるため、複数端末での同時実行は避ける

---

## 機能B: タスク取り込み

Discord #iris チャンネルのメッセージを解釈し、Apple Reminders の「やること」リストにタスクを追加する。

### 実行手順

#### 1. メッセージ取得

```bash
bash .hestia/scripts/task.sh
```

JSON 配列が返る。各要素の `content` フィールドがメッセージ本文、`id` が Discord メッセージ ID。

#### 2. メッセージ解釈

- **タスク名**: メッセージ本文から期限表現を除いたテキスト
- **期限**: 自然言語を JST の日時に変換する
  - 指定なし → 今日の 23:59
  - 「明日」→ 翌日 0:00
  - 「明日15時」→ 翌日 15:00
  - 「今週金曜」→ 直近の金曜 0:00
- タスク名の末尾に必ず ` #日常` を付与する

#### 3. リマインダー作成

各タスクに対して osascript を実行する。日付は計算した値を直接埋め込む:

```bash
osascript << 'APPLESCRIPT'
tell application "Reminders"
    set d to (current date)
    set year of d to YYYY
    set month of d to MM
    set day of d to DD
    set hours of d to HH
    set minutes of d to MIN
    set seconds of d to 0
    make new reminder in list "やること" with properties {name:"タスク名 #日常", due date:d}
end tell
APPLESCRIPT
```

#### 4. 処理済みIDを保存

全メッセージの処理後、最後のメッセージ ID を保存する（次回実行時の重複防止）:

```bash
echo "LAST_MESSAGE_ID" > .hestia/task_last_id
```

#### 5. 報告

- 追加したタスクの一覧（タスク名 + 設定した期限）
- 処理したメッセージ数
- メッセージがなかった場合は「新しいメッセージはありませんでした」

### 注意点

- `task.sh` は `bot: true` なメッセージを除外済みなので全件処理してよい
- メッセージが空配列 `[]` の場合は何もせず終了
- `.hestia/task_last_id` が存在しない場合は直近50件を対象にする
- リスト名は必ず `"やること"` を使う