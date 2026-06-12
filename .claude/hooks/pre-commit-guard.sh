#!/bin/bash
INPUT=$(cat)
CMD=$(echo "$INPUT" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('tool_input', {}).get('command', ''))" 2>/dev/null)

if [[ "$CMD" != *"git commit"* ]]; then exit 0; fi

ERRORS=""
WARNINGS=""

if git diff --cached --name-only 2>/dev/null | grep -q "^\.env$"; then
  ERRORS="$ERRORS\n🚫 .env is staged. Remove it: git restore --staged .env"
fi

STAGED_DART=$(git diff --cached --name-only 2>/dev/null | grep "\.dart$")
if [ -n "$STAGED_DART" ]; then
  while IFS= read -r file; do
    [ -f "$file" ] || continue
    MATCHES=$(grep -n "^\s*print(" "$file" 2>/dev/null)
    if [ -n "$MATCHES" ]; then
      WARNINGS="$WARNINGS\n⚠️  $file:\n$MATCHES"
    fi
  done <<< "$STAGED_DART"
fi

if [ -n "$ERRORS" ]; then
  echo -e "PRE-COMMIT BLOCKED:$ERRORS"
  exit 2
fi

if [ -n "$WARNINGS" ]; then
  MSG="PRE-COMMIT WARNING — Active print() found:$WARNINGS"
  echo "{\"continue\": true, \"hookSpecificOutput\": {\"hookEventName\": \"PreToolUse\", \"additionalContext\": \"$MSG\"}}"
fi

exit 0
