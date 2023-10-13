---@type ChadrcConfig
local M = {}

-- Path to overriding theme and highlights files
local highlights = require "custom.highlights"

M.ui = {
  theme = "catppuccin",
  theme_toggle = { "catppuccin", "catppuccin" },

  hl_override = highlights.override,
  hl_add = highlights.add,

  changed_themes = {
    catppuccin = {
      base_30 = {
        dark_red = "#f44336",
        sapphire = "#74c7ec",
        surface1 = "#45475a"
      }
    }
  },

  transparency = true,

  cheatsheet = { theme = "simple" },

  nvdash = {
    load_on_startup = true,
  },

  tabufline = {
    enabled = false,
  },

  statusline = {
    theme = "default",
    overriden_modules = function(modules)
      -- local st_modules = require "nvchad_ui.statusline.default"
      modules[2] = (function()
        local fileInfo = function()
          local default_sep_icons = {
            default = { left = "", right = " " },
            round = { left = "", right = "" },
            block = { left = "█", right = "█" },
            arrow = { left = "", right = "" },
          }
          local icon = " 󰈚 "
          local path = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(vim.g.statusline_winid))
          local name = (path == "" and "Empty ") or path:match "^.+[/\\](.+)$"
          local foldername = (path == "" and "Empty ") or path:match(".+/") and path:match("^.+/(.+)/.+$")

          local modified_indicator = ""
          if vim.bo.modified then
            modified_indicator = " "
          end

          if name ~= "Empty " then
            local devicons_present, devicons = pcall(require, "nvim-web-devicons")
            if devicons_present then
              local ft_icon = devicons.get_icon(name)
              icon = (ft_icon ~= nil and " " .. ft_icon) or ""
            end

            name = " " .. (foldername or "") .. " -> " .. name .. modified_indicator .. " "
          end

          return "%#St_file_info#" .. icon .. name .. "%#St_file_sep#" .. default_sep_icons.default.right
        end
        return fileInfo()
      end)()
    end
  }
}

M.plugins = "custom.plugins"

-- check core.mappings for table structure
M.mappings = require "custom.mappings"

-- START Custom Vim Settings
vim.opt.relativenumber = true
vim.opt.iskeyword:append("-")
vim.opt.cursorline = true
vim.opt.colorcolumn = '80'
vim.opt.scrolloff = 8
vim.opt.fillchars:append { diff = "╱" }
-- END Custom Vim Settings

-- START Custom Functions
-- set neorg file setting
vim.api.nvim_create_autocmd({"BufEnter","BufWinEnter"},{
  pattern = {"*.norg"},
  command = "set conceallevel=3"
})

-- quickfix list delete keymap
function Remove_qf_item()
  local curqfidx = vim.fn.line('.')
  local qfall = vim.fn.getqflist()

  -- Return if there are no items to remove
  if #qfall == 0 then return end

  -- Remove the item from the quickfix list
  table.remove(qfall, curqfidx)
  vim.fn.setqflist(qfall, 'r')

  -- Reopen quickfix window to refresh the list
  vim.cmd('copen')  

  -- If not at the end of the list, stay at the same index, otherwise, go one up.
  local new_idx = curqfidx < #qfall and curqfidx or math.max(curqfidx - 1, 1)

  -- Set the cursor position directly in the quickfix window
  local winid = vim.fn.win_getid() -- Get the window ID of the quickfix window
  vim.api.nvim_win_set_cursor(winid, {new_idx, 0})
end

vim.cmd("command! RemoveQFItem lua Remove_qf_item()")
vim.api.nvim_command("autocmd FileType qf nnoremap <buffer> dd :RemoveQFItem<cr>")
-- END Custom Functions

-- START wezterm tweaks
-- local pwd = vim.cmd(pwd);
-- vim.cmd('lua require("wezterm").set_tab_title("one more")')
-- END wezterm tweaks

return M
