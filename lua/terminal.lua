-- Floating terminal, toggled like VSCode's integrated terminal.
-- Buffer is kept alive across toggles so the shell session persists.

local term_buf = nil
local term_win = nil

local function open_terminal()
  if term_buf == nil or not vim.api.nvim_buf_is_valid(term_buf) then
    term_buf = vim.api.nvim_create_buf(false, true)
  end

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  term_win = vim.api.nvim_open_win(term_buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  if vim.bo[term_buf].buftype ~= "terminal" then
    vim.fn.termopen(vim.o.shell)
  end

  vim.cmd("startinsert")
end

local function close_terminal()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_hide(term_win)
  end
  term_win = nil
end

local function toggle_terminal()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    close_terminal()
  else
    open_terminal()
  end
end

-- `<C-`>` may not reach nvim in some terminal emulators (no distinct
-- keycode for Ctrl+backtick over plain TTY), so `<leader>t` is a
-- guaranteed-to-work fallback.
vim.keymap.set({ "n", "t" }, "<C-`>", toggle_terminal, { silent = true, desc = "Toggle terminal" })
vim.keymap.set("n", "<leader>t", toggle_terminal, { silent = true, desc = "Toggle terminal" })
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { silent = true, desc = "Exit terminal mode" })
