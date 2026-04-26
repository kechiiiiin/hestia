---
name: collect-diary
description: Discord に届いた本日の日記Q&Aを取り込み、journal/YYYY-MM-DD.md を再生成する。「日記を集めて」「日記を更新」「今日の回答を取り込んで」「日記まとめて」などのリクエストで使う。
---

# Diary Collection

ユーザーが Discord に投稿した本日分の回答を、Bot API 経由で取得して `journal/YYYY-MM-DD.md` に集約する skill。

## 実行手順

1. プロジェクトルートで収集スクリプトを実行する:

   ```bash
   bash .hestia/scripts/collect.sh
   ```

2. 生成された日記ファイルの中身を確認・表示する:

   ```bash
   cat "journal/$(TZ=Asia/Tokyo date '+%Y-%m-%d').md"
   ```

3. ユーザーに以下を報告する:
   - 取り込まれた質問の数
   - 各質問への回答有無
   - 回答が `_(回答なし)_` になっている質問があれば、それを示唆

## 注意点

- スクリプトは**冪等**。実行のたびに `.md` を再生成するので、何度走らせても問題ない（遅れて返信した回答も次回実行時に拾える）
- Discord API は1回で最新100件まで取得。1日分の Q&A（最大16通=8質問+8回答）には十分
- `.hestia/config.env` に `DISCORD_BOT_TOKEN` と `DISCORD_CHANNEL_ID` が必要。CI ではなくローカル実行限定
- `journal/` 配下は Obsidian Sync で他デバイスに同期される想定なので、競合を避けるため複数端末で同時実行しない