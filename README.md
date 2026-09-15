# Zenbones for Herdr

12 color themes from the [zenbones](https://github.com/zenbones-theme/zenbones.nvim) ecosystem for the [Herdr](https://herdr.dev) terminal multiplexer. HSLuv-based palettes, light and dark variants, works in any terminal.

## Themes

| Theme | Variants | Description |
|---|---|---|
| **zenbones** | light, dark | The base theme — contrast-focused, warm accents |
| **zenwritten** | light, dark | Zero saturation, pure grayscale + zenbones accents |
| **neobones** | light, dark | Inspired by neovim.io — green-leaning |
| **forestbones** | light, dark | Inspired by Everforest — natural greens and golds |
| **rosebones** | light, dark | Inspired by Rose Pine — purple and rose tones |
| **tokyobones** | light, dark | Inspired by Tokyo Night — deep blue-violet |
| **seoulbones** | light, dark | Inspired by Seoul256 — balanced mid-tones |
| **nordbones** | dark only | Inspired by Nord — arctic blues |
| **duckbones** | dark only | Inspired by Spaceduck — high contrast space |
| **zenburned** | dark only | Inspired by Zenburn — muted warm gray |
| **kanagawabones** | dark only | Inspired by Kanagawa — Japanese ink wash |
| **vimbones** | light only | Inspired by vim.org — warm yellow-green |

## Installation

```bash
herdr plugin install AkashJana18/zenbones-herdr
```

Or from a local checkout:

```bash
herdr plugin link /path/to/zenbones-herdr
```

Marketplace listing requires the repository topic `herdr-plugin`.

## Usage

Open the theme picker:

```
prefix+shift+z
```

Or invoke directly:

```bash
herdr plugin action invoke open --plugin zenbones
```

Apply a specific theme directly:

```bash
./bin/apply.sh tokyobones-dark
./bin/apply.sh zenbones-light
./bin/apply.sh nordbones-dark
```

Or via the CLI picker invocation:

```bash
herdr plugin action invoke open --plugin zenbones
```

Available slugs: `zenbones-light`, `zenbones-dark`, `neobones-light`, `neobones-dark`, `nordbones-dark`, `tokyobones-light`, `tokyobones-dark`, `seoulbones-light`, `seoulbones-dark`, `duckbones-dark`, `zenburned-dark`, `kanagawabones-dark`, `zenwritten-light`, `zenwritten-dark`, `forestbones-light`, `forestbones-dark`, `rosebones-light`, `rosebones-dark`, `vimbones-light`.

## What is modified

The plugin writes a `[theme.custom]` block to `~/.config/herdr/config.toml` (or `$HERDR_CONFIG_PATH`). Backups are created as `config.toml.bak-YYYYMMDD`. The plugin runs `herdr server reload-config` after writing. To revert, remove the `[theme.custom]` block or restore the backup.

Each file in `themes/` contains the 19 Herdr theme tokens (`panel_bg`, `sidebar_bg`, `text`, `accent`, `red`, `green`, ...) pre-computed from the source palette, so there is no runtime color conversion.

## Compatibility

- Herdr `>=0.8.0`
- Platforms: Linux, macOS
- Requires: `bash`, `awk`, `grep` (standard on all Unix systems)
- Optional: `fzf` for the interactive picker (falls back to numbered menu)

## Credits

All color palettes are ported from the [zenbones](https://github.com/zenbones-theme/zenbones.nvim) Neovim colorscheme by [winston@wintrcat.uk](https://github.com/zenbones-theme). Zenbones uses HSLuv perceptually uniform color space for palette generation. Individual theme inspirations:

- **nordbones** — [Nord](https://www.nordtheme.com) by Arctic Ice Studio
- **tokyobones** — [Tokyo Night](https://github.com/enkia/tokyo-night-vscode-theme) by enkia
- **seoulbones** — [Seoul256](https://github.com/junegunn/seoul256.vim) by Junegunn Choi
- **duckbones** — [Spaceduck](https://github.com/pinespiders/spaceduck) by pinespider
- **zenburned** — [Zenburn](https://github.com/jnurmine/Zenburn) by Jalil Nilour
- **kanagawabones** — [Kanagawa](https://github.com/rebelot/kanagawa.nvim) by rebelot
- **forestbones** — [Everforest](https://github.com/sainnhe/everforest) by sainnhe
- **rosebones** — [Rose Pine](https://github.com/rose-pine/neovim) by _s T l
- **vimbones** — inspired by vim.org's classic green-on-cream palette

## License

MIT. See [LICENSE](LICENSE).
