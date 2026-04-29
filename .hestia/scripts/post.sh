#!/bin/bash
# 質問を Discord webhook で投稿。
# - 引数で時刻指定可（省略時は現在時刻 JST）
# - DISCORD_WEBHOOK_URL は env 優先、なければ ../config.env から読む（CI / ローカル両対応）
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [[ -z "${DISCORD_WEBHOOK_URL:-}" ]] && [[ -f "$REPO_ROOT/.hestia/config.env" ]]; then
  source "$REPO_ROOT/.hestia/config.env"
fi

HOUR="${1:-$(TZ=Asia/Tokyo date +%-H)}"
QUESTION=$(jq -r --arg h "$HOUR" '.[$h] // empty' "$REPO_ROOT/.hestia/questions.json")

if [[ -z "$QUESTION" ]]; then
  echo "no question for hour $HOUR"
  exit 0
fi

CONTENT="$QUESTION"
PAYLOAD=$(jq -n --arg c "$CONTENT" '{content: $c, username: "Hestia", avatar_url: "https://images.kechiiiiin.com/icon/20260427230742.jpeg"}')

curl -sS -X POST -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  "$DISCORD_WEBHOOK_URL" > /dev/null

echo "posted ${HOUR}:00"
