#!/usr/bin/env bash
# maps ghostty palette -> herdr [theme.custom] tokens
# keep TOKEN_ORDER in sync with palette_to_tokens
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

TOKEN_ORDER=(panel_bg sidebar_bg active_row_bg selection_bg text surface0 surface1 overlay0 overlay1 subtext0 accent blue mauve green yellow red teal peach surface_dim)

token_origin() {
  case "$1" in
    panel_bg) echo "background" ;;
    sidebar_bg) echo "background −12%" ;;
    active_row_bg) echo "palette 0" ;;
    selection_bg) echo "selection-background" ;;
    text) echo "foreground" ;;
    surface0) echo "palette 0" ;;
    surface1|overlay0) echo "palette 8" ;;
    overlay1|subtext0) echo "palette 7" ;;
    accent|blue) echo "palette 4" ;;
    mauve) echo "palette 5" ;;
    green) echo "palette 2" ;;
    yellow) echo "palette 3" ;;
    red) echo "palette 1" ;;
    teal) echo "palette 6" ;;
    peach) echo "palette 9" ;;
    surface_dim) echo "background −8%" ;;
    *) echo "?" ;;
  esac
}

token_role() {
  case "$1" in
    panel_bg) echo "pane background" ;;
    sidebar_bg) echo "sidebar background" ;;
    active_row_bg) echo "selected sidebar row" ;;
    selection_bg) echo "text selection bg" ;;
    text) echo "primary text" ;;
    surface0) echo "sidebar row bg" ;;
    surface1) echo "inactive pane bg" ;;
    overlay0) echo "dim surfaces" ;;
    overlay1) echo "bright text" ;;
    subtext0) echo "secondary text" ;;
    accent) echo "active pane border / selector" ;;
    blue) echo "links / info" ;;
    mauve) echo "accent (blossom)" ;;
    green) echo "success ✓ (leaf)" ;;
    yellow) echo "warning (wood)" ;;
    red) echo "error ✗ (rose)" ;;
    teal) echo "sky / now-playing" ;;
    peach) echo "accent (wood light)" ;;
    surface_dim) echo "dividers" ;;
    *) echo "" ;;
  esac
}

_pget() {
  local file="$1" key="$2"
  if [[ "$key" == p* ]]; then
    grep -E "^palette *= *${key#p}=" "$file" | head -1 | sed 's/.*=//; s/[[:space:]]*$//'
  else
    grep -E "^${key} *=" "$file" | head -1 | sed 's/^[^=]*= *//; s/[[:space:]]*$//'
  fi
}

palette_to_tokens() {
  local f="$1" bg fg sel p0 p1 p2 p3 p4 p5 p6 p7 p8 p9
  p0="$(_pget "$f" p0)"; [ -n "$p0" ] || die "not a valid ghostty palette: $f (missing palette 0)"
  bg="$(_pget "$f" background)"; fg="$(_pget "$f" foreground)"
  sel="$(_pget "$f" selection-background)"
  p1="$(_pget "$f" p1)"; p2="$(_pget "$f" p2)"; p3="$(_pget "$f" p3)"
  p4="$(_pget "$f" p4)"; p5="$(_pget "$f" p5)"; p6="$(_pget "$f" p6)"
  p7="$(_pget "$f" p7)"; p8="$(_pget "$f" p8)"; p9="$(_pget "$f" p9)"
  # fallbacks
  : "${sel:=$p0}"
  : "${p8:=$p0}"
  : "${p9:=$p3}"
  : "${bg:?missing background}"; : "${fg:?missing foreground}"
  local derived
  derived="$(printf 'panel_bg=%s\nsidebar_bg=%s\nactive_row_bg=%s\nselection_bg=%s\nsurface0=%s\nsurface1=%s\nsurface_dim=%s\noverlay0=%s\noverlay1=%s\ntext=%s\nsubtext0=%s\naccent=%s\nmauve=%s\ngreen=%s\nyellow=%s\nred=%s\nblue=%s\nteal=%s\npeach=%s\n' \
    "$bg" "$(darken_hex "$bg" 12)" "$p0" "$sel" "$p0" "$p8" "$(darken_hex "$bg" 8)" "$p8" "$p7" "$fg" "$p7" \
    "$p4" "$p5" "$p2" "$p3" "$p1" "$p4" "$p6" "$p9")"
  printf '%s\n' "$derived"
}
