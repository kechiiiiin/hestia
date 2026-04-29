#!/bin/bash
# task チャンネルの未処理メッセージを取得して stdout に JSON で出力
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [[ -z "${DISCORD_BOT_TOKEN:-}" ]] && [[ -f "$REPO_ROOT/.hestia/config.env" ]]; then
  source "$REPO_ROOT/.hestia/config.env"
fi

IRIS_CHANNEL_ID="1498884657108746372"
LAST_ID_FILE="$REPO_ROOT/.hestia/task_last_id"

PARAMS="limit=50"
if [[ -f "$LAST_ID_FILE" ]]; then
  LAST_ID=$(cat "$LAST_ID_FILE")
  PARAMS="${PARAMS}&after=${LAST_ID}"
fi

curl -sS -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  "https://discord.com/api/v10/channels/${IRIS_CHANNEL_ID}/messages?${PARAMS}" | \
  python3 -c "
import sys, json
msgs = json.load(sys.stdin)
# ユーザーメッセージのみ（botを除外）、時系列順に並べる
msgs = [m for m in msgs if not m.get('author', {}).get('bot', False)]
msgs.reverse()
print(json.dumps(msgs, ensure_ascii=False, indent=2))
"