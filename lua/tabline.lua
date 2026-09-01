-- Buffer-based tabline, similar to VSCode's open-file tabs.

local function listed_bufs()
  return vim.fn.getbufinfo({ buflisted = 1 })
end

function _G._tabline()
  local bufs = listed_bufs()
  local cur = vim.fn.bufnr()
  local s = ""
  for i, buf in ipairs(bufs) do
    local name = vim.fn.fnamemodify(buf.name, ":t")
    if name == "" then
      name = "[No Name]"
    end
    local modified = buf.changed == 1 and " ●" or ""
    local hl = buf.bufnr == cur and "%#TabLineSel#" or "%#TabLine#"
    s = s .. hl .. " " .. i .. ": " .. name .. modified .. " %*"
  end
  return s .. "%#TabLineFill#"
end

vim.o.showtabline = 2
vim.o.tabline = "%!v:lua._tabline()"

for i = 1, 9 do
  vim.keymap.set("n", "<leader>" .. i, function()
    local bufs = listed_bufs()
    if bufs[i] then
      vim.cmd("buffer " .. bufs[i].bufnr)
    end
  end, { silent = true, desc = "Go to tab " .. i })
end

vim.keymap.set("n", "<leader>bn", ":bnext<cr>", { silent = true, desc = "Next tab" })
vim.keymap.set("n", "<leader>bp", ":bprevious<cr>", { silent = true, desc = "Previous tab" })
vim.keymap.set("n", "<leader>bd", ":confirm bdelete<cr>", { silent = true, desc = "Close tab" })
