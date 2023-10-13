local M = {}

-- START treesitter
M.treesitter = {
  ensure_installed = {
    "vim",
    "lua",
    "html",
    "css",
    "javascript",
    "typescript",
    "tsx",
    "c",
    "markdown",
    "markdown_inline",
  },
  indent = {
    enable = true,
    -- disable = {
    --   "python"
    -- },
  },
}
-- END treesitter

-- START indent-blankline
vim.opt.list = true
vim.opt.listchars:append "space:⋅"
vim.opt.listchars:append "eol:↴"
-- END indent-blankline

-- START cmp
M.cmp = {
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer",
      option = {
        get_bufnrs = function()
          return vim.api.nvim_list_bufs()
        end
      }
    },
    { name = "nvim_lua" },
    { name = "path" },
    { name = "codeium" },
    { name = "orgmode" },
  }
}
-- END cmp

-- START nvim-colorizer
M.nvim_colorizer = {
  user_default_options = {
    tailwind = true,
  },
}
-- END nvim-colorizer

-- START mason
M.mason = {
  ensure_installed = {
    -- lua stuff
    "lua-language-server",
    "stylua",

    -- web dev stuff
    "css-lsp",
    "html-lsp",
    "typescript-language-server",
    "deno",
    "prettier",

    -- c/cpp stuff
    "clangd",
    "clang-format",
  },
}
-- END mason

-- START nvimtree
M.nvimtree = {
  git = {
    enable = true,
  },

  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },

  view = {
    centralize_selection = false,
    adaptive_size = false,
    side = 'right',
    preserve_window_proportions = true,
    float = {
      enable = false,
      quit_on_focus_loss = false,
      open_win_config = function()
        return {
          row = 0,
          width = 35,
          border = "rounded",
          relative = "editor",
          col = vim.o.columns,
          height = vim.o.lines,
        }
      end
    }
  }
}
-- END nvimtree

-- START telescope
M.telescope = {
  extensions = {
    undo = {
      side_by_side = true,
      -- layout_strategy = "vertical",
      layout_config = {
        width = 0.9,
        height = 0.9,
        preview_width = 0.8
      },
    },
  },
  function(_, opts)
    local function flash(prompt_bufnr)
      require("flash").jump({
        pattern = "^",
        label = { after = { 0, 0 } },
        search = {
          mode = "search",
          exclude = {
            function(win)
              return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
            end,
          },
        },
        action = function(match)
          local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
          picker:set_selection(match.pos[1] - 1)
        end,
      })
    end
    opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
      mappings = {
        n = { s = flash },
        i = { ["<c-s>"] = flash },
      },
    })
  end
}
-- END telescope

return M
