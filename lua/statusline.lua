local pms = vim.api.nvim_get_hl(0, { name = "PmenuSel", link = false })
local dir = vim.api.nvim_get_hl(0, { name = "Directory", link = false })
local vis = vim.api.nvim_get_hl(0, { name = "Visual", link = false })
vim.api.nvim_set_hl(0, "StlMode", { fg = pms.fg, bg = vis.bg })
vim.api.nvim_set_hl(0, "StlGit", { fg = dir.fg, bg = pms.bg })

local modes = {
  n = "NORMAL",
  i = "INSERT",
  v = "VISUAL",
  V = "V-LINE",
  ["\22"] = "V-BLOCK",
  c = "COMMAND",
  t = "TERMINAL",
  R = "REPLACE",
  s = "SELECT",
  S = "S-LINE",
  ["\19"] = "S-BLOCK",
}

function _G._statusline()
  local mode = modes[vim.fn.mode()] or vim.fn.mode():upper()
  local branch = vim.b.git_branch and "%#StlGit# " .. vim.b.git_branch .. " %*" or ""
  local path = vim.b.rel_path or "%f"

  local diag = ""
  local counts = vim.diagnostic.count(0) or {}
  local labels = { "  ", "  ", "  ", "  " }
  local hls = { "DiagnosticError", "DiagnosticWarn", "DiagnosticInfo", "DiagnosticHint" }
  for i = 1, 4 do
    if counts[i] and counts[i] > 0 then
      diag = diag .. "%#" .. hls[i] .. "%#" .. labels[i] .. counts[i] .. "%* "
    end
  end

  return "%#StlMode# " .. mode .. " %*" .. branch .. " " .. path .. "%=" .. diag .. vim.bo.filetype .. " %l:%c"
end

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    -- Set a synchronous fallback immediately so the statusline isn't stale
    vim.b.rel_path = vim.fn.expand("%:p:~")

    vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true }, function(root_out)
      local root = vim.trim(root_out.stdout or "")
      if root_out.code ~= 0 or root == "" then
        return
      end

      vim.system({ "git", "branch", "--show-current" }, { text = true }, function(branch_out)
        vim.schedule(function()
          if not vim.api.nvim_buf_is_valid(bufnr) then
            return
          end
          vim.b[bufnr].git_branch = vim.trim(branch_out.stdout or "")
          vim.b[bufnr].rel_path = vim.api.nvim_buf_get_name(bufnr):sub(#root + 2)
          vim.cmd("redrawstatus!")
        end)
      end)
    end)
  end,
})

vim.api.nvim_create_autocmd("DiagnosticChanged", {
  callback = function()
    vim.cmd("redrawstatus!")
  end,
})

vim.o.statusline = "%!v:lua._statusline()"
