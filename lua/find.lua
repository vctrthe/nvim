local ignore_patterns = {
  "node_modules",
  "%.git",
  "%.cache",
  "dist",
  "build",
  "%.tmp",
  "%.log",
}

local file_cache = nil
local cache_cwd = nil

local function scan_files()
  local files = vim.fn.glob("**/*", true, true)
  local result = {}
  for _, f in ipairs(files) do
    if vim.fn.isdirectory(f) == 0 then
      local skip = false
      for _, pat in ipairs(ignore_patterns) do
        if f:match(pat) then
          skip = true
          break
        end
      end
      if not skip then
        result[#result + 1] = f
      end
    end
  end
  return result
end

function _G.native_find(text, _)
  local cwd = vim.fn.getcwd()
  if not file_cache or cache_cwd ~= cwd then
    file_cache = scan_files()
    cache_cwd = cwd
  end
  return vim.fn.matchfuzzy(file_cache, text)
end

-- Invalidate cache when files change on disk or cwd changes
vim.api.nvim_create_autocmd({ "DirChanged", "FocusGained", "BufWritePost" }, {
  callback = function()
    file_cache = nil
  end,
})

vim.opt.findfunc = "v:lua.native_find"

vim.keymap.set("n", "<leader>f", ":find ", { silent = false })
