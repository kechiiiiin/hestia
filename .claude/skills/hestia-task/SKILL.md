---
name: hestia-task
description: Discord #iris チャンネルのメッセージを解釈し、Apple Reminders の「やること」リストにタスクを追加する。「タスクを取り込んで」「タスクを追加して」「リマインダーに追加して」で起動。
---

# Hestia タスク取り込み

Discord #iris チャンネルのメッセージを解釈し、Apple Reminders の「やること」リストにタスクを追加する。

## 実行手順

### 1. メッセージ取得

```bash
bash .hestia/scripts/task.sh
```

JSON 配列が返る。各要素の `content` フィールドがメッセージ本文、`id` が Discord メッセージ ID。

### 2. メッセージ解釈

- **タスク名**: メッセージ本文そのまま（期限表現が含まれていても除かなくてよい）

### 3. リマインダー作成

各タスクに対して Shortcuts.app 経由で登録する。タグ「日常」は Shortcut 側で自動付与される:

```bash
echo '{"name":"タスク名"}' | shortcuts run "hestia タスク追加"
```

### 4. 処理済みIDを保存

全メッセージの処理後、最後のメッセージ ID を保存する（次回実行時の重複防止）:

```bash
echo "LAST_MESSAGE_ID" > .hestia/task_last_id
```

### 5. 報告

- 追加したタスクの一覧（タスク名）
- 処理したメッセージ数
- メッセージがなかった場合は「新しいメッセージはありませんでした」

## 注意点

- `task.sh` は `bot: true` なメッセージを除外済みなので全件処理してよい
- メッセージが空配列 `[]` の場合は何もせず終了
- `.hestia/task_last_id` が存在しない場合は直近50件を対象にする
- Shortcuts.app に「hestia タスク追加」ショートカットが必要（JSON の `name` キーを受け取りタグ「日常」付きで「やること」リストに追加する）