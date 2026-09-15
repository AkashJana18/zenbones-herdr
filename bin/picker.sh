#!/usr/bin/env bash
set -euo pipefail
_here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_here/lib.sh"

themes=()
while IFS= read -r line; do
  [ -n "$line" ] && themes+=("$line")
done < <(list_themes)
[ ${#themes[@]} -gt 0 ] || die "no themes found in $INDEX_FILE"

current=""
[ -f "$APPLIED_FILE" ] && current="$(cat "$APPLIED_FILE" 2>/dev/null || true)"

SELECTED=""

entry() {
  local slug="$1" display="${1//-/ }"
  if [ "$slug" = "$current" ]; then
    printf '%s\t%s  (current)\n' "$slug" "$display"
  else
    printf '%s\t%s\n' "$slug" "$display"
  fi
}

pick() {
  local all=("${themes[@]}" "default")
  if command -v fzf >/dev/null 2>&1; then
    local chosen
    chosen="$(
      for t in "${all[@]}"; do entry "$t"; done |
        fzf --delimiter='\t' --with-nth=2.. --prompt='zenbones> ' --height=100% --no-multi || true
    )"
    [ -n "$chosen" ] || return 0
    SELECTED="${chosen%%$'\t'*}"
  else
    printf '\n zenbones themes\n\n'
    for i in "${!all[@]}"; do
      [ "${all[$i]}" = "$current" ] && suffix='  (current)' || suffix=''
      printf '  [%d] %s%s\n' "$((i + 1))" "${all[$i]//-/ }" "$suffix"
    done
    printf '\n  theme number> '
    local num
    read -r num
    [ -n "$num" ] || return 0
    [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#all[@]}" ] || return 0
    SELECTED="${all[$((num - 1))]}"
  fi
}

pick
[ -n "$SELECTED" ] || exit 0
exec bash "$_here/apply.sh" "$SELECTED"
