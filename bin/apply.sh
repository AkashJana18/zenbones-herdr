#!/usr/bin/env bash
set -euo pipefail
_here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_here/lib.sh"
source "$_here/map.sh"

# ---- config writers ----

# Remove existing [theme.custom] block, then append new one.
write_custom_block() {
  local cfg="$1" tokens="$2"
  awk '
    /^\[theme\.custom\]$/ { skip=1; next }
    /^\[theme\.custom\./ { skip=1; next }
    skip && /^\[/ { skip=0 }
    !skip { print }
  ' "$cfg" > "$cfg.tmp"
  {
    printf '\n[theme.custom]\n'
    while IFS='=' read -r k v; do
      [ -n "$k" ] && printf '%s = "%s"\n' "$k" "$v"
    done <<< "$tokens"
  } >> "$cfg.tmp"
  mv "$cfg.tmp" "$cfg"
}

# Write [theme.custom.light] or [theme.custom.dark]
write_mode_block() {
  local cfg="$1" mode="$2" tokens="$3"
  local header="[theme.custom.$mode]"
  awk -v h="$header" '
    $0 == h { skip=1; next }
    skip && /^\[/ { skip=0 }
    !skip { print }
  ' "$cfg" > "$cfg.tmp"
  {
    printf '\n%s\n' "$header"
    while IFS='=' read -r k v; do
      [ -n "$k" ] && printf '%s = "%s"\n' "$k" "$v"
    done <<< "$tokens"
  } >> "$cfg.tmp"
  mv "$cfg.tmp" "$cfg"
}

# Ensure [theme] section exists and set auto_switch
ensure_theme_auto() {
  local cfg="$1" val="$2" # true/false
  if ! grep -q "^\[theme\]" "$cfg"; then
    printf '\n[theme]\nname = "catppuccin"\n' >> "$cfg"
  fi
  # replace or insert auto_switch inside [theme] block
  if grep -q "auto_switch" "$cfg"; then
    # use awk to replace inside [theme] section only
    awk -v v="$val" '
      /^\[theme\]$/ { in_theme=1; print; next }
      /^\[/ { in_theme=0 }
      in_theme && /^[[:space:]]*auto_switch[[:space:]]*=/ { print "auto_switch = " v; next }
      { print }
    ' "$cfg" > "$cfg.tmp" && mv "$cfg.tmp" "$cfg"
  else
    awk '
      /^\[theme\]$/ { print; print "auto_switch = true"; next }
      { print }
    ' "$cfg" > "$cfg.tmp" && mv "$cfg.tmp" "$cfg"
    # if val is false, fix
    if [ "$val" = "false" ]; then
      awk '
        /^\[theme\]$/ { in_theme=1; print; next }
        /^\[/ { in_theme=0 }
        in_theme && /auto_switch = true/ { sub("true","false") }
        { print }
      ' "$cfg" > "$cfg.tmp" && mv "$cfg.tmp" "$cfg"
    fi
  fi
  # also ensure dark_name/light_name exist for predictability when auto
  if [ "$val" = "true" ]; then
    if ! grep -q "dark_name" "$cfg"; then
      awk '/^\[theme\]$/ {print; print "dark_name = \"catppuccin\""; next}1' "$cfg" > "$cfg.tmp" && mv "$cfg.tmp" "$cfg"
    fi
    if ! grep -q "light_name" "$cfg"; then
      awk '/^\[theme\]$/ {print; print "light_name = \"catppuccin-latte\""; next}1' "$cfg" > "$cfg.tmp" && mv "$cfg.tmp" "$cfg"
    fi
  fi
}

apply_single() {
  local slug="$1"
  local palette tokens
  palette="$(resolve_palette "$slug")"
  [ -f "$palette" ] || die "palette not found: $palette (slug: $slug)"
  tokens="$(palette_to_tokens "$palette")" || die "invalid palette: $slug"
  [ -n "$tokens" ] || die "invalid palette: $slug"

  ensure_config_exists
  local stamp; stamp="$(date +%Y%m%d)"
  local bak="$CONFIG_PATH.bak-$stamp"
  [ -f "$bak" ] || cp "$CONFIG_PATH" "$bak"

  # For single mode we clear mode blocks to avoid confusion, keep only [theme.custom]
  # Remove light/dark subtables
  awk '
    /^\[theme\.custom\.light\]$/ { skip=1; next }
    /^\[theme\.custom\.dark\]$/ { skip=1; next }
    skip && /^\[/ { skip=0 }
    !skip { print }
  ' "$CONFIG_PATH" > "$CONFIG_PATH.tmp" && mv "$CONFIG_PATH.tmp" "$CONFIG_PATH"

  write_custom_block "$CONFIG_PATH" "$tokens"
  ensure_theme_auto "$CONFIG_PATH" "false"

  mkdir -p "$STATE_DIR"
  printf '%s\n' "$slug" > "$APPLIED_FILE"

  if herdr server reload-config >/dev/null 2>&1; then
    printf 'Applied Zenwritten %s → %s\n' "$slug" "$CONFIG_PATH"
  else
    printf 'Zenwritten %s written to %s, but reload failed. Try: herdr server reload-config\n' "$slug" "$CONFIG_PATH" >&2
  fi
}

apply_auto() {
  local light_palette dark_palette light_tokens dark_tokens
  light_palette="$(resolve_palette light)"
  dark_palette="$(resolve_palette dark)"
  [ -f "$light_palette" ] || die "missing light palette"
  [ -f "$dark_palette" ] || die "missing dark palette"
  light_tokens="$(palette_to_tokens "$light_palette")"
  dark_tokens="$(palette_to_tokens "$dark_palette")"

  ensure_config_exists
  local stamp; stamp="$(date +%Y%m%d)"
  local bak="$CONFIG_PATH.bak-$stamp"
  [ -f "$bak" ] || cp "$CONFIG_PATH" "$bak"

  # Write base [theme.custom] as light fallback + both mode blocks
  write_custom_block "$CONFIG_PATH" "$light_tokens"
  write_mode_block "$CONFIG_PATH" "light" "$light_tokens"
  write_mode_block "$CONFIG_PATH" "dark" "$dark_tokens"
  ensure_theme_auto "$CONFIG_PATH" "true"

  mkdir -p "$STATE_DIR"
  printf 'auto\n' > "$APPLIED_FILE"

  if herdr server reload-config >/dev/null 2>&1; then
    printf 'Applied Zenwritten auto (light+dark) → %s\n' "$CONFIG_PATH"
  else
    printf 'Zenwritten auto written to %s, but reload failed. Try: herdr server reload-config\n' "$CONFIG_PATH" >&2
  fi
}

do_toggle() {
  local cur=""
  [ -f "$APPLIED_FILE" ] && cur="$(cat "$APPLIED_FILE" 2>/dev/null || true)"
  case "$cur" in
    light|zenwritten-light) apply_single dark ;;
    dark|zenwritten-dark) apply_single light ;;
    auto) apply_single light ;;
    *) # fallback: check config for panel_bg darkness
       if grep -q '#191919' "$CONFIG_PATH" 2>/dev/null; then apply_single light; else apply_single dark; fi
       ;;
  esac
}

main() {
  local cmd="${1:-}"
  case "$cmd" in
    light) apply_single light ;;
    dark) apply_single dark ;;
    auto) apply_auto ;;
    toggle) do_toggle ;;
    ""|help|-h|--help)
      cat <<'USAGE'
zenwritten apply.sh — apply Zenwritten theme to Herdr

Usage:
  apply.sh light        Apply light paper theme (#eeeeee)
  apply.sh dark         Apply dark ink theme (#191919)
  apply.sh auto         Apply both + enable auto_switch (light/dark follow system)
  apply.sh toggle       Toggle between last applied variants

Config: $HERDR_CONFIG_PATH or ~/.config/herdr/config.toml
Palettes: themes/zenwritten-light, themes/zenwritten-dark
Tokens: mapped via bin/map.sh → [theme.custom] (see herdr --default-config)
Herdr only — no outer terminal changes.
USAGE
      ;;
    *) die "unknown command: $cmd (try: light, dark, auto, toggle)" ;;
  esac
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then main "$@"; fi
