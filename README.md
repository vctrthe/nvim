# nvim_native

Minimal Neovim config built on native features only — no plugin manager, no
plugins. LSP via built-in `vim.lsp`, file finding via `findfunc`, grep via
`grepprg` + quickfix, file explorer via `netrw`.

Leader key: `<space>`

## Key notation

Vim keymap notation, translated to macOS keys:

| Notation | macOS key |
|---|---|
| `<leader>` | `Space bar` (`mapleader = " "` in `init.lua`) |
| `<C-x>` | `Control + x` (physical **Control** key, not `Cmd`) |
| `<C-`>` | `Control + \`` (backtick) — not guaranteed to reach nvim on every terminal app, see `<leader>t` fallback below |
| `<Esc>` | `Esc` |
| `<S-x>` | `Shift + x` |
| `<A-x>` | `Option + x` (`Alt`) |

## Requirements

- Neovim 0.11+
- `rg` (ripgrep) — grep
- `lua-language-server`, `gopls`, `tsc` (TypeScript 7.0+), `docker-language-server`, `csharp-ls` — LSP servers (only needed for the filetypes you use)
- `stylua`, `prettier`, `gofmt`, `dotnet-csharpier` — formatters (only needed for the filetypes you use)

## Keymaps

| Keymap | Mode | Action |
|---|---|---|
| `<leader>w` | Normal | Write (save) current buffer |
| `<leader>q` | Normal | Quit current window |
| `U` | Normal | Redo (`<C-r>`) |
| `<C-h>` | Normal | Move to left split |
| `<C-j>` | Normal | Move to below split |
| `<C-k>` | Normal | Move to above split |
| `<C-l>` | Normal | Move to right split |
| `<leader>d` | Normal | Send diagnostics to quickfix and open it |
| `<leader>f` | Normal | Fuzzy find file (`:find`, native `findfunc`) |
| `<leader>g` | Normal | Prompt for a pattern, `grep!` it, open quickfix |
| `<leader>e` | Normal | Toggle netrw file explorer (`:Lexplore`) |
| `%` | Normal (netrw buffer only) | Create a new file/directory in the previous window |
| `<C-`>` / `<leader>t` | Normal, Terminal | Toggle floating terminal (session persists while hidden) |
| `<Esc>` | Terminal | Exit terminal mode (`<C-\><C-n>`) |
| `<leader>1` .. `<leader>9` | Normal | Jump to tab (buffer) N |
| `<leader>bn` | Normal | Next tab |
| `<leader>bp` | Normal | Previous tab |
| `<leader>bd` | Normal | Close current tab (`:confirm bdelete`) |

## Vim essentials (builtin, not set by this config)

These aren't custom keymaps — they're Vim's own defaults, listed here because
they're the ones you'll use constantly.

**Modes**

| Keymap | Action |
|---|---|
| `i` | Insert before cursor |
| `a` | Insert after cursor |
| `o` / `O` | New line below / above, enter insert mode |
| `v` | Visual mode (character select) |
| `<S-v>` | Visual line mode (select whole lines) |
| `<C-v>` | Visual block mode (select a column/rectangle) |
| `<Esc>` | Back to Normal mode |

**Edit**

| Keymap | Action |
|---|---|
| `x` | Delete character under cursor |
| `dd` | Delete (cut) current line |
| `dw` | Delete to end of word |
| `D` | Delete to end of line |
| `yy` | Yank (copy) current line |
| `yw` | Yank to end of word |
| `p` / `P` | Paste after / before cursor |
| `u` | Undo |
| `U` | Redo (remapped in this config, see `lua/keymaps.lua` — Vim's default `U` is "undo whole line", not used here) |
| `.` | Repeat last change |
| In Visual mode: `d` / `y` | Delete / yank the selection |

**Move around**

| Keymap | Action |
|---|---|
| `h j k l` | Left, down, up, right |
| `w` / `b` | Next / previous word start |
| `e` | End of word |
| `0` / `$` | Start / end of line |
| `gg` / `G` | Top / bottom of file |
| `<C-d>` / `<C-u>` | Half page down / up |
| `%` | Jump to matching bracket (outside netrw, where `%` is remapped — see above) |

**Search**

| Keymap | Action |
|---|---|
| `/pattern` | Search forward |
| `?pattern` | Search backward |
| `n` / `N` | Next / previous match |

**Command line**

| Keymap | Action |
|---|---|
| `:w` | Save (also `<leader>w` in this config) |
| `:q` | Quit (also `<leader>q` in this config) |
| `:wq` | Save and quit |
| `:q!` | Quit without saving |

## Other behavior (not keymaps)

- Yanked text is briefly highlighted.
- Cursor is restored to the last-known position when reopening a file.
- Files are auto-formatted on save (see `lua/formatting.lua` for the
  filetype → formatter table); falls back to LSP formatting if no external
  formatter is configured for the filetype. A failed formatter shows a
  `vim.notify` warning instead of failing silently.
- Completion auto-triggers on LSP attach (`noselect` so nothing is inserted
  until you pick an item).
- Statusline shows mode, git branch, path relative to git root, diagnostics
  counts, filetype, and cursor position. Git info is fetched asynchronously
  so entering a buffer never blocks on `git`.

## Structure

```
init.lua                 entrypoint, loads everything below
lua/options.lua           vim.o settings
lua/keymaps.lua           general keymaps
lua/lsp.lua                lsp.enable() + completion on attach
lua/diagnostics.lua        diagnostics keymap
lua/formatting.lua         format-on-save
lua/find.lua                native fuzzy file finder
lua/grep.lua                grep via grepprg + quickfix
lua/netrw.lua               netrw config + file creation
lua/statusline.lua          custom statusline
lua/tabline.lua              buffer-based tabs (VSCode-style)
lua/terminal.lua             floating terminal toggle
lua/colorscheme.lua         colorscheme
lua/autocommands.lua        misc autocommands
lsp/*.lua                   per-server LSP configs (picked up automatically
                             by vim.lsp.enable())
```
