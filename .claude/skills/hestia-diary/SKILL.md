---
name: hestia-diary
description: Discord に届いた本日分の Q&A を取り込み、journal/YYYY-MM-DD.md を再生成する。「日記を集めて」「日記を更新」「今日の回答を取り込んで」「日記まとめて」で起動。
---

# Hestia 日記収集

Discord に届いた本日分の Q&A を取り込み、`journal/YYYY-MM-DD.md` を再生成する。

## 実行手順

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

## 注意点

- スクリプトは**冪等**。何度実行しても問題ない
- Discord API は1回で最新100件まで取得。1日分には十分
- `.hestia/config.env` に `DISCORD_BOT_TOKEN` と `DISCORD_CHANNEL_ID` が必要
- `journal/` は Obsidian Sync で同期されるため、複数端末での同時実行は避ける