-- local autocmd = vim.api.nvim_create_autocmd

-- Auto resize panes when resizing nvim window
-- autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })
local opt = vim.opt
opt.clipboard = ""

require("custom.configs.user_commands")

vim.cmd([[
augroup ufo_detach
  autocmd!
  autocmd FileType org UfoDetach
augroup END
]])

-- vim.api.nvim_create_autocmd({"BufWinEnter"},{
--   pattern = {"*.*"},
--   callback = function()  require('specs').show_specs() end
-- })
