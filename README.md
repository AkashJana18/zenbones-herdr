# Zenwritten for Herdr

Minimal paper theme for Herdr. Port of [zenbones](https://github.com/zenbones-theme/zenbones.nvim) `zenwritten` for the Herdr TUI.

Source palette: `hsluv(0,0,94)` paper `#eeeeee`, `hsluv(0,0,22)` ink `#353535` (light) and `hsluv(0,0,9)` `#191919` / `hsluv(0,0,76)` `#bbbbbb` (dark), with zenbones accent hues.

## Compatibility

- Herdr `>=0.8.0` (tested on `0.9.0`)
- Platforms: Linux, macOS, Windows
- Linux/macOS: `bash`, `awk`, `grep`, `ps`
- Windows: PowerShell 5.1+ (`powershell.exe`)

No additional dependencies.

## Installation

From GitHub:

```bash
herdr plugin install AkashJana18/zenwritten-herdr
```

From local checkout:

```bash
herdr plugin link /path/to/zenwritten-herdr
herdr plugin list
herdr plugin action list --plugin zenwritten
```

Marketplace listing requires the repository topic `herdr-plugin`. The index refreshes every 30 minutes.

## Usage

Herdr exposes plugin actions in all contexts (`global`, `workspace`, `tab`, `pane`). Invoke via the command palette or CLI.

CLI:

```bash
herdr plugin action invoke zenwritten.light --plugin zenwritten   # or dark, auto, toggle
herdr plugin action invoke zenwritten.dark --plugin zenwritten
herdr plugin action invoke zenwritten.auto --plugin zenwritten
herdr plugin action invoke zenwritten.toggle --plugin zenwritten
```

On Windows the action IDs are `zenwritten.light-win`, `zenwritten.dark-win`, `zenwritten.auto-win`, `zenwritten.toggle-win`.

Direct execution:

```bash
./bin/apply.sh light
./bin/apply.sh dark
./bin/apply.sh auto
./bin/apply.sh toggle
```

PowerShell (Windows):

```powershell
.\bin\apply.ps1 light
.\bin\apply.ps1 dark
.\bin\apply.ps1 auto
.\bin\apply.ps1 toggle
```

`light` | `dark` writes a single `[theme.custom]` block and sets `auto_switch = false`. `auto` writes `[theme.custom]` (fallback) plus `[theme.custom.light]` and `[theme.custom.dark]` and sets `auto_switch = true`.

## What is modified

Target file: `~/.config/herdr/config.toml` (or `$HERDR_CONFIG_PATH`). The plugin edits only theme keys.

```toml
[theme]
name = "vesper"       # preserved
auto_switch = false    # true after `auto`

[theme.custom]
panel_bg = "#eeeeee"
sidebar_bg = "#d1d1d1"
active_row_bg = "#c5c0c0"
selection_bg = "#d9d9d9"
text = "#353535"
subtext0 = "#686868"
accent = "#286486"
red = "#a8334c"
green = "#4f6c31"
yellow = "#944927"
blue = "#286486"
mauve = "#88507d"
teal = "#3b8992"
peach = "#c49a6c"
# ... plus surface0, surface1, surface_dim, overlay0, overlay1
```

Backups are created as `config.toml.bak-YYYYMMDD` (one per day). The plugin runs `herdr server reload-config` after writing. If reload fails, run it manually.

To revert, remove the `[theme.custom]` blocks or restore the backup.

## Palette

Files in `themes/` are 16-color palettes in Ghostty format. The format is used as a compact interchange for the 16 ANSI colors and does not require Ghostty. The plugin uses them only to derive Herdr UI tokens.

- `themes/zenwritten-light` — `background #eeeeee`, `foreground #353535`, `palette 0 #c5c0c0`, `1 #a8334c`, `2 #4f6c31`, `3 #944927`, `4 #286486`, `5 #88507d`, `6 #3b8992`, `7 #686868`
- `themes/zenwritten-dark` — `background #191919`, `foreground #bbbbbb`, `palette 0 #3f393b`, `1 #de6e7c`, `2 #819b69`, `3 #b77e64`, `4 #6099c0`, `5 #b279a7`, `6 #66a5ad`, `7 #818181`

Mapping to Herdr tokens is defined in `bin/map.sh:64`:

| Herdr token | Palette source |
|---|---|
| `panel_bg` | `background` |
| `sidebar_bg` | `background` darkened 12% |
| `active_row_bg`, `surface0` | `palette 0` |
| `selection_bg` | `selection-background` |
| `text` | `foreground` |
| `subtext0`, `overlay1` | `palette 7` |
| `surface1`, `overlay0` | `palette 8` |
| `surface_dim` | `background` darkened 8% |
| `accent`, `blue` | `palette 4` |
| `red` | `palette 1` |
| `green` | `palette 2` |
| `yellow` | `palette 3` |
| `mauve` | `palette 5` |
| `teal` | `palette 6` |
| `peach` | `palette 9` |

Herdr UI theming via `[theme.custom]` works in any terminal emulator. The plugin does not modify the outer terminal.

## Relation to built-in themes

Herdr ships 18 built-ins (`catppuccin`, `tokyo-night`, `gruvbox`, `vesper`, etc. at `src/config/theme.rs`). This plugin does not replace them. It provides a lower-saturation paper alternative via `[theme.custom]`, which is the recommended extension point (`herdr.dev/docs/configuration#theme`).

## License

MIT. See `LICENSE`.
