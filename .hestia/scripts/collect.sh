#!/bin/bash
# Discord 履歴から本日分の Q&A を取得し journal/YYYY-MM-DD.md を再生成（冪等）
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [[ -z "${DISCORD_BOT_TOKEN:-}" ]] && [[ -f "$REPO_ROOT/.hestia/config.env" ]]; then
  source "$REPO_ROOT/.hestia/config.env"
fi

JOURNAL_DIR="$REPO_ROOT/journal"
mkdir -p "$JOURNAL_DIR"

TODAY=$(TZ=Asia/Tokyo date '+%Y-%m-%d')
JOURNAL_FILE="$JOURNAL_DIR/$TODAY.md"
TODAY_START_UTC=$(TZ=Asia/Tokyo date -j -f "%Y-%m-%d %H:%M:%S" "$TODAY 00:00:00" "+%s")

MESSAGES=$(curl -sS -H "Authorization: Bot $DISCORD_BOT_TOKEN" \
  "https://discord.com/api/v10/channels/$DISCORD_CHANNEL_ID/messages?limit=100")

TODAY_MSGS=$(echo "$MESSAGES" | jq --argjson start "$TODAY_START_UTC" '
  map(select(
    (.timestamp | sub("\\.[0-9]+"; "") | sub("\\+00:00"; "Z") | fromdateiso8601) >= $start
  )) | reverse
')

SECTIONS=$(echo "$TODAY_MSGS" | jq -r '
  . as $msgs
  | [range(0; length)] as $idxs
  | $idxs
  | map(. as $i | $msgs[$i] |
      select(.webhook_id != null and (.content | test("^❓ \\*\\*\\d+:00\\*\\*")))
      | {idx: $i, content: .content}
    )
  | . as $qs
  | [range(0; length)]
  | map(
      . as $j
      | $qs[$j] as $q
      | (if $j+1 < ($qs|length) then $qs[$j+1].idx else ($msgs|length) end) as $nextIdx
      | $msgs[($q.idx + 1):$nextIdx]
      | map(select(.webhook_id == null) | .content)
      | {header: $q.content, replies: .}
    )
  | .[]
  | "## \(.header | sub("^❓ \\*\\*"; "") | sub("\\*\\*"; ""))\n\n" +
    (if (.replies | length) == 0 then "_(回答なし)_\n"
     else (.replies | map("> " + (gsub("\n"; "\n> "))) | join("\n>\n")) + "\n"
     end)
')

{
  echo "# $TODAY"
  echo
  if [[ -n "$SECTIONS" ]]; then
    echo "$SECTIONS"
  fi
} > "$JOURNAL_FILE"

echo "collected → $JOURNAL_FILE"
