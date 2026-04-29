---
name: hestia-all
description: hestia-diary と hestia-task を順番に実行する。「全部まとめて」「hestia all」「日記とタスクを取り込んで」で起動。
---

# Hestia 全スキル実行

以下の順番で各スキルを Skill ツールで呼び出す。

1. `hestia-diary` スキルを実行する
2. `hestia-task` スキルを実行する

各スキルが完了したら、両方の結果をまとめてユーザーに報告する。

## 注意点

- 一方が失敗しても、もう一方は続行する
- 各スキルの詳細な手順・注意点はそれぞれの SKILL.md に従う