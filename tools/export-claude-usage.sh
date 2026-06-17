#!/usr/bin/env bash
#
# export-claude-usage.sh
#
# Gathers your local Claude Code session transcripts into a single .jsonl file
# that you can drag into dashboard.html. Zero dependencies — just bash + find.
#
# Usage:
#   ./tools/export-claude-usage.sh [OUTPUT_FILE] [CLAUDE_DIR]
#
#   OUTPUT_FILE  Where to write the combined transcript.
#               Default: ./claude-usage.jsonl
#   CLAUDE_DIR   Claude Code data directory.
#               Default: $HOME/.claude
#
# The dashboard parses everything in the browser; nothing is uploaded anywhere.

set -euo pipefail

OUT="${1:-./claude-usage.jsonl}"
CLAUDE_DIR="${2:-$HOME/.claude}"
PROJECTS_DIR="$CLAUDE_DIR/projects"

if [ ! -d "$PROJECTS_DIR" ]; then
    echo "No transcripts found at: $PROJECTS_DIR" >&2
    echo "Set the directory explicitly: $0 $OUT /path/to/.claude" >&2
    exit 1
fi

# Collect every .jsonl transcript (including subagent transcripts) into one file.
: > "$OUT"
count=0
while IFS= read -r -d '' f; do
    cat "$f" >> "$OUT"
    # Ensure a trailing newline between files so lines never merge.
    printf '\n' >> "$OUT"
    count=$((count + 1))
done < <(find "$PROJECTS_DIR" -type f -name '*.jsonl' -print0)

lines=$(grep -c . "$OUT" 2>/dev/null || echo 0)
echo "Combined $count transcript file(s) → $OUT (${lines} records)."
echo "Now open dashboard.html in a browser and drop in: $OUT"
