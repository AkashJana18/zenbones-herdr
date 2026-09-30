#!/usr/bin/env bash
set -euo pipefail
_here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_here/lib.sh"

strip_theme_custom() {
  local cfg="$1"
  awk '
    /^\[theme\.custom(\.[a-z0-9_]+)*\]$/ { skip=1; next }
    skip && /^\[[^]]*\]$/ { skip=0 }
    !skip { print }
  ' "$cfg" > "$cfg.tmp" && mv "$cfg.tmp" "$cfg"
}

write_custom_block() {
  local cfg="$1" theme="$2"
  {
    printf '\n[theme.custom]\n'
    tr -d '\r' < "$theme" | grep '^[a-z0-9_]* *= *"'
  } >> "$cfg"
}

trim_trailing_newlines() {
  local cfg="$1"
  awk '
    { lines[NR] = $0 }
    END {
      last = NR
      while (last > 0 && lines[last] ~ /^[[:space:]]*$/) last--
      if (last == 0) print ""
      else for (i = 1; i <= last; i++) print lines[i]
    }
  ' "$cfg" > "$cfg.trim" && mv "$cfg.trim" "$cfg"
}

notify_theme() {
  local slug="$1"
  mkdir -p "$STATE_DIR"
  printf '%s\n' "$slug" > "$APPLIED_FILE"

  if "${HERDR_BIN_PATH:-herdr}" server reload-config >/dev/null 2>&1; then
    printf 'Applied %s → %s\n' "$slug" "$CONFIG_PATH"
  else
    printf '%s written to %s (reload failed — run: herdr server reload-config)\n' "$slug" "$CONFIG_PATH" >&2
  fi
}

apply_theme() {
  local slug="$1"

  ensure_config_exists
  local stamp; stamp="$(date +%Y%m%d)"
  local bak="$CONFIG_PATH.bak-$stamp"
  [ -f "$bak" ] || cp "$CONFIG_PATH" "$bak"

  strip_theme_custom "$CONFIG_PATH"
  trim_trailing_newlines "$CONFIG_PATH"

  if [ "$slug" = "default" ]; then
    notify_theme default
    return
  fi

  local theme
  theme="$(resolve_theme "$slug")"
  write_custom_block "$CONFIG_PATH" "$theme"
  trim_trailing_newlines "$CONFIG_PATH"
  notify_theme "$slug"
}

main() {
  local slug="${1:-}"
  [ -n "$slug" ] || die "usage: apply.sh <theme-slug>\navailable: default $(list_themes | tr '\n' ' ')"
  apply_theme "$slug"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then main "$@"; fi