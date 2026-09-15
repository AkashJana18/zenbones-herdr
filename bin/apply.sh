#!/usr/bin/env bash
set -euo pipefail
_here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_here/lib.sh"

write_custom_block() {
  local cfg="$1" theme="$2"
  awk '
    /^\[theme\.custom\]$/ { skip=1; next }
    /^\[theme\.custom\./ { skip=1; next }
    skip && /^\[/ { skip=0 }
    !skip { print }
  ' "$cfg" > "$cfg.tmp"
  {
    printf '\n[theme.custom]\n'
    grep '^[a-z0-9_]* *= *"' "$theme"
  } >> "$cfg.tmp"
  mv "$cfg.tmp" "$cfg"
}

apply_theme() {
  local slug="$1"
  local theme
  theme="$(resolve_theme "$slug")"

  ensure_config_exists
  local stamp; stamp="$(date +%Y%m%d)"
  local bak="$CONFIG_PATH.bak-$stamp"
  [ -f "$bak" ] || cp "$CONFIG_PATH" "$bak"

  awk '
    /^\[theme\.custom\.light\]$/ { skip=1; next }
    /^\[theme\.custom\.dark\]$/ { skip=1; next }
    skip && /^\[/ { skip=0 }
    !skip { print }
  ' "$CONFIG_PATH" > "$CONFIG_PATH.tmp" && mv "$CONFIG_PATH.tmp" "$CONFIG_PATH"

  write_custom_block "$CONFIG_PATH" "$theme"

  mkdir -p "$STATE_DIR"
  printf '%s\n' "$slug" > "$APPLIED_FILE"

  if herdr server reload-config >/dev/null 2>&1; then
    printf 'Applied %s → %s\n' "$slug" "$CONFIG_PATH"
  else
    printf '%s written to %s (reload failed — run: herdr server reload-config)\n' "$slug" "$CONFIG_PATH" >&2
  fi
}

main() {
  local slug="${1:-}"
  [ -n "$slug" ] || die "usage: apply.sh <theme-slug>\navailable: $(list_themes | tr '\n' ' ')"
  apply_theme "$slug"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then main "$@"; fi