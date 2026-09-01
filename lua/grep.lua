vim.opt.grepprg = "rg --vimgrep --smart-case --hidden"
  .. " --glob '!.git' --glob '!node_modules' --glob '!dist' --glob '!build'"
vim.opt.grepformat = "%f:%l:%c:%m"

vim.keymap.set("n", "<leader>g", function()
  vim.ui.input({ prompt = "Grep: " }, function(pattern)
    if pattern then
      vim.cmd("silent grep! " .. vim.fn.fnameescape(pattern))
      vim.cmd("copen")
    end
  end)
end, { silent = true })
