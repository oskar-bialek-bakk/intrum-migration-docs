#!/usr/bin/env bash
# build_docs.sh — Assembles documentation from template.md by replacing
# <!-- include: path --> directives with the contents of the referenced files.
#
# Usage: bash build_docs.sh [output_path]
#   output_path  defaults to ../dokumentacja_dla_zespolu_zewnetrznego.md
#                (relative to this script's directory)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$SCRIPT_DIR/template.md"
OUTPUT="${1:-$SCRIPT_DIR/../dokumentacja_dla_zespolu_zewnetrznego.md}"

if [[ ! -f "$TEMPLATE" ]]; then
  echo "ERROR: template not found: $TEMPLATE" >&2
  exit 1
fi

> "$OUTPUT"

while IFS= read -r line || [[ -n "$line" ]]; do
  if [[ "$line" =~ ^'<!-- include: '(.+)' -->'$ ]]; then
    include_path="$SCRIPT_DIR/${BASH_REMATCH[1]}"
    if [[ ! -f "$include_path" ]]; then
      echo "ERROR: included file not found: $include_path" >&2
      exit 1
    fi
    cat "$include_path" >> "$OUTPUT"
  else
    printf '%s\n' "$line" >> "$OUTPUT"
  fi
done < "$TEMPLATE"

echo "Built: $OUTPUT"
