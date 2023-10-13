local overrides = require("custom.configs.overrides")
local utils = require("custom.utils.utils")
local lua_ufo = function(ufo_cmd)
	return [[lua require("ufo").]] .. ufo_cmd .. [[()]]
end

---@type NvPluginSpec[]
local plugins = {

  -- Override plugin definition options

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- format & linting
      {
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
          require "custom.configs.null-ls"
        end,
      },
    },
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end, -- Override to setup mason-lspconfig
  },

  -- override plugin configs
  {
    "williamboman/mason.nvim",
    opts = overrides.mason
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event= "VeryLazy",
    config = function()
      local highlight = {
        "RainbowDark",
        "RainbowBrown",
        "RainbowPeach",
        "RainbowLightGreen",
        "RainbowOrange"
      }

      local hooks = require "ibl.hooks"
      -- create the highlight groups in the highlight setup hook, so they are reset
      -- every time the colorscheme changes
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "RainbowDark", { fg = "#393646" })
        vim.api.nvim_set_hl(0, "RainbowBrown", { fg = "#6D5D6E" })
        vim.api.nvim_set_hl(0, "RainbowPeach", { fg = "#f5e0dc" })
        vim.api.nvim_set_hl(0, "RainbowLightGreen", { fg = "#DFFFD8" })
        vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#f9e2af" })
      end)
      require('ibl').setup {
        -- show_end_of_line = true,
        scope = {
          enabled = false
        },
        -- show_current_context = false,
        -- show_current_context_start = false,
        exclude = {
          filetypes = {
            'neogit'
          }
        },
        indent = {
          highlight = highlight,
          char = "▏"
        }
      }
    end
  },

  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
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
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = overrides.treesitter,
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      { "roobert/tailwindcss-colorizer-cmp.nvim", config = true },
    },
    opts = overrides.cmp,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },

  {
    "NvChad/nvim-colorizer.lua",
    opts = {
      overrides.nvim_colorizer
    }
  },

  -- Install a plugin
  {
    "MunifTanjim/prettier.nvim",
    event = "VeryLazy",
    config = function()
      require("prettier").setup()
    end
  },

  {
    -- https://github.com/ThePrimeagen/git-worktree.nvim/pull/106
    "brandoncc/git-worktree.nvim",
    event = "VeryLazy",
    branch = "catch-and-handle-telescope-related-error",
    config = function(_, opts)
      local Worktree = require("git-worktree")
      Worktree.setup(opts)

      local Job = require("plenary.job")

      Worktree.on_tree_change(function(op, metadata)
        if op == Worktree.Operations.Switch then
          local pane_name = utils.shorten(metadata.path, 20, true)

          if vim.t.zellij_worktree_switch_history == nil then
						vim.t.zellij_worktree_switch_history = {}
					end

					-- Stop further execution if there's already a floating pane
					-- for this worktree
					if vim.tbl_contains(vim.t.zellij_worktree_switch_history, metadata.path) then
						return
					end

          local function toggle_zellij_floating_window()
            Job:new({
              command = "zellij",
              args = {
                "action",
                "toggle-floating-panes",
              },
              }):start()
          end

          local function rename_zellij_pane()
            Job:new({
              command = "zellij",
              args = {
                "action",
                "rename-pane",
                pane_name,
              },
              on_exit = toggle_zellij_floating_window,
              }):start()
          end

          local function new_zellij_floating_pane()
            Job:new({
              command = "zellij",
              args = {
                "run",
                "-f",
                "--",
                "zsh",
              },
              on_exit = function()
                local history = vim.t.zellij_worktree_switch_history
                table.insert(history, 1, metadata.path)
                vim.t.zellij_worktree_switch_history = history

                rename_zellij_pane()
              end,
              }):start()
          end

          new_zellij_floating_pane()
        end
      end)

      require("telescope").load_extension("git_worktree")
    end,
  },

  {
    'glacambre/firenvim',
    -- Lazy load firenvim
    -- Explanation: https://github.com/folke/lazy.nvim/discussions/463#discussioncomment-4819297
    lazy = not vim.g.started_by_firenvim,
    build = function()
      vim.fn["firenvim#install"](0)
    end
  },


  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        char = {
          jump_labels = true
        }
      }
    },
    keys = {
      {
        "sw",
        mode = { "n", "x" },
        function()
          -- jump to word under cursor
          require("flash").jump({pattern = vim.fn.expand("<cword>")})
       end,
      },
      {
        "ss",
        mode = { "n", "x" },
        function()
          -- default options: exact mode, multi window, all directions, with a backdrop
          require("flash").jump()
       end,
      },
      {
        "ss",
        mode = { "o" },
        function()
          require("flash").jump()
        end,
      },
      {
        "<leader>ss",
        mode = { "o", "x" },
        function()
          require("flash").treesitter()
        end,
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "<leader>t",
        mode = { "o", "x", "n" },
        function()
          local win = vim.api.nvim_get_current_win()
          local view = vim.fn.winsaveview()
          require("flash").jump({
            action = function(match, state)
              state:hide()
              vim.api.nvim_set_current_win(match.win)
              vim.api.nvim_win_set_cursor(match.win, match.pos)
              require("flash").treesitter()
              vim.schedule(function()
                vim.api.nvim_set_current_win(win)
                vim.fn.winrestview(view)
              end)
            end,
          })
        end,
      },
    },
  },

  {
    'ThePrimeagen/harpoon',
    event = "VeryLazy",
    opts = {},
    config = function()
      require("telescope").load_extension('harpoon');
    end
  },

  {
    'kdheepak/lazygit.nvim',
    lazy = false,
  },

  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },

  {
    "kevinhwang91/nvim-ufo",
    dependencies = "kevinhwang91/promise-async",
    event = "VeryLazy",
    config = function ()
      local u = utils

      local _, maxheight = u.screen_scale({ height = 0.65 })
      require('ufo').setup({
        fold_virt_text_handler = require("custom.utils.ufo").handler,
        preview = {
          win_config = {
            maxheight = maxheight,
            winhighlight = "Normal:Folded",
            winblend = 0,
          },
          mappings = {
            scrollU = "<C-u>",
            scrollD = "<C-d>",
          },
        },
        close_fold_kinds = {
          "imports",
          "comment",
        },
      })
      vim.keymap.set('n', '<leader>pf', function()
        local winid = require('ufo').peekFoldedLinesUnderCursor()
        if not winid then
          vim.lsp.buf.hover()
        end
      end)
    end,
    init = function()
      vim.o.foldcolumn = "0"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
    end,
    keys = {
      utils.lazy_map("zR", lua_ufo("openAllFolds")),
      utils.lazy_map("zM", lua_ufo("closeAllFolds")),
      utils.lazy_map("zr", lua_ufo("openFoldsExceptKinds")),
      utils.lazy_map("zm", lua_ufo("closeFoldsWith")),
      utils.lazy_map("]z", lua_ufo("goNextClosedFold")),
      utils.lazy_map("[z", lua_ufo("goPreviousClosedFold")),
      utils.lazy_map("<leader>fp", "FoldParagraph"),
    },
  },

  {
    'echasnovski/mini.nvim',
    lazy = false,
    config = function()
      require('mini.cursorword').setup()
      require('mini.splitjoin').setup()
      require('mini.sessions').setup()
      require('mini.files').setup({
        windows = {
          preview = true,
          width_preview = 50
        },
        options = {
          use_as_default_explorer = false,
        },
        mappings = {
          close       = 'q',
          go_in       = '<CR>',
          go_in_plus  = 'L',
          go_out      = '-',
          go_out_plus = 'H',
          reset       = '<BS>',
          show_help   = 'g?',
          synchronize = '=',
          trim_left   = '<',
          trim_right  = '>',
        },
      })

      local show_dotfiles = true
      local MiniFiles = require("mini.files")
      local filter_show = function(fs_entry) return true end
      local filter_hide = function(fs_entry) return not vim.startswith(fs_entry.name, ".") end

      local toggle_dotfiles = function()
        show_dotfiles = not show_dotfiles
        local new_filter = show_dotfiles and filter_show or filter_hide
        require("mini.files").refresh({ content = { filter = new_filter } })
      end

      local map_split = function(buf_id, lhs, direction)
        local rhs = function()
          -- Make new window and set it as target
          local new_target_window
          vim.api.nvim_win_call(MiniFiles.get_target_window(), function()
            vim.cmd(direction .. ' split')
            new_target_window = vim.api.nvim_get_current_win()
          end)

          MiniFiles.set_target_window(new_target_window)
        end

        -- Adding `desc` will result into `show_help` entries
        local desc = 'Split ' .. direction
        vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = desc })
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          local buf_id = args.data.buf_id
          vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id })
          map_split(buf_id, 'gs', 'belowright horizontal')
          map_split(buf_id, 'gv', 'belowright vertical')
        end,
      })
    end
  },

  {
    "Pocco81/true-zen.nvim",
    lazy = false,
    config = function()
      require("true-zen").setup {
        -- your config goes here
        -- or just leave it empty :)
      }
    end,
  },

  {
    'edluffy/specs.nvim',
    event = "VeryLazy",
    config = function()
      require('specs').setup{
        show_jumps  = true,
        min_jump = 30,
        popup = {
          delay_ms = 0, -- delay before popup displays
          inc_ms = 10, -- time increments used for fade/resize effects 
          blend = 10, -- starting blend, between 0-100 (fully transparent), see :h winblend
          width = 97,
          winhl = "Cursor",
          fader = require('specs').exp_fader,
          resizer = require('specs').shrink_resizer
        },
        ignore_filetypes = {},
        ignore_buftypes = {
          nofile = true,
        },
      }
    end
  },

  {
    'tpope/vim-fugitive',
    event = "VeryLazy"
  },

  {
    'j-morano/buffer_manager.nvim',
    event = "VeryLazy",
    config = function()
      require("buffer_manager").setup({
        select_menu_item_commands = {
          v = {
            key = "<C-v>",
            command = "vsplit"
          },
          h = {
            key = "<C-h>",
            command = "split"
          }
        },
        focus_alternate_buffer = true,
        loop_nav = true,
        width = 90,
        height = 25,
        short_file_names = true,
        short_term_names = true
      })
    end
  },

  {
    "roobert/tailwindcss-colorizer-cmp.nvim",
    lazy = false,
    -- optionally, override the default options:
    config = function()
      require("tailwindcss-colorizer-cmp").setup({
        color_square_width = 2,
      })
    end
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    lazy = false,
  },

  {
    "utilyre/barbecue.nvim",
    lazy = false,
    name = "barbecue",
    version = "*",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons", -- optional dependency
    },
    opts = {
      -- configurations go here
    },
  },

  {
    "liangxianzhe/nap.nvim",
    enabled = false,
    lazy = false,
    config = function()
      require("nap").setup()
    end
  },

  {
    "mg979/vim-visual-multi",
    lazy = false,
    config = function()
      -- require("nap").setup()
    end
  },

  {
    'willothy/wezterm.nvim',
    lazy = false,
    config = true,
    -- opts = {
    --   create_commands = false
    -- },
    -- config = function()
    --   local wezterm = require 'wezterm'
    --   wezterm.set_tab_title('Test')
    -- end
  },

  {
    'stevearc/oil.nvim',
    lazy = false,
    config = function()
      require("oil").setup({
        view_options = {
          show_hidden = true,
        },
      });
    end
  },

  {
    "debugloop/telescope-undo.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("telescope").load_extension("undo")
      -- optional: vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>")
    end,
  },

  {
    "mbbill/undotree",
    event = "VeryLazy",
  },

  {
    "epwalsh/obsidian.nvim",
    lazy = false,
    event = { "BufReadPre " .. vim.fn.expand "~" .. "/Library/Mobile Documents/com~apple~CloudDocs/Obsidian/Vault of Lykos/**.md" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
      "nvim-telescope/telescope.nvim",
      "godlygeek/tabular",
      "preservim/vim-markdown",
    },
    config = function()
      require("obsidian").setup{
        dir = "~/Library/Mobile Documents/com~apple~CloudDocs/Obsidian/Vault of Lykos",
        notes_subdir = "nvim_notes",
        daily_notes = {
          folder = '3. Fleeting/Journal/Daily'
        },
        templates = {
          subdir = "Templates",
          date_format = "%Y-%m-%d-%a",
          time_format = "%H:%M"
        },
        -- ensure_installed = { "markdown", "markdown_inline", ... },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = { "markdown" },
        },
        note_frontmatter_func = function(note)
          local out = { id = note.id, aliases = note.aliases, tags = note.tags, created = note.cday, updated = note.mday }
          if note.metadata ~= nil and require("obsidian").util.table_length(note.metadata) > 0 then
            for k, v in pairs(note.metadata) do
              out[k] = v
            end
          end
          return out
        end,
        note_id_func = function(title)
          local suffix = ""
          if title ~= nil then
            suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
          else
            for _ = 1, 4 do
              suffix = suffix .. string.char(math.random(65, 90))
            end
          end
          return title
        end,
        completion = {
          nvim_cmp = true,
        },
      }

      vim.keymap.set("n", "gf", function()
        if require("obsidian").util.cursor_on_markdown_link() then
          return "<cmd>ObsidianFollowLink<CR>"
        else
          return "gf"
        end
      end, { noremap = false, expr = true })
    end,
  },

  {
    'joaomsa/telescope-orgmode.nvim',
    event = "VeryLazy",
    config = function()
      require('telescope').load_extension('orgmode')
    end
  },

  {
    'nvim-orgmode/orgmode',
    event="VeryLazy",
    config = function()
      require('orgmode').setup_ts_grammar()

      require('nvim-treesitter.configs').setup {
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = {'org'},
        },
        ensure_installed = {'org'}, -- Or run :TSUpdate org
      }

      local Menu = require('custom.plugins.org-modern.menu')

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'org',
        group = vim.api.nvim_create_augroup('orgmode_telescope_nvim', { clear = true }),
        callback = function()
          vim.keymap.set('n', '<leader>or', require('telescope').extensions.orgmode.refile_heading)
        end,
      })

      require('orgmode').setup({
        ui = {
          menu = {
            handler = function(data)
              Menu:new({
                window = {
                  margin = { 1, 0, 1, 0 },
                  padding = { 0, 1, 0, 1 },
                  title_pos = "center",
                  border = "single",
                  zindex = 1000,
                },
                icons = {
                  separator = "➜",
                },
              }):open(data)
            end,
          },
        },
        -- org_agenda_files = {'~/orgmode_nvim/org/*', '~/my-orgs/**/*'},
        -- org_default_notes_file = '~/orgmode_nvim/org/refile.org',
        org_agenda_files = {'~/org/*', '~/my-orgs/**/*'},
        org_default_notes_file = '~/org/refile.org',
        org_capture_templates = {
          t = {
            description = 'Todos',
            template = '** TODO %?\n %u\n',
            target = '~/org/todos.org',
            headline = 'Inbox',
          },
          m = {
            description = 'Meetings',
            template = '** MEETING %? :meeting:\n SCHEDULED: %T\n Meeting with: \n*** Notes: \n %u\n',
            target = '~/org/meetings.org',
            headline = 'Meetings',
          },
          n = {
            description = 'Notes',
            template = '** %? :notes:\n %u',
            target = '~/org/meetings.org'
          },
        },
        org_todo_keywords = {'TODO(t)', 'PROGRESS(p)', '|', 'DONE(d)', 'CANCELLED(c)', 'WAITING(w)', 'MEETING(m)'},
        org_todo_keyword_faces = {
          TODO = ':foreground #DF8C97 :weight bold', -- overrides builtin color for `TODO` keyword
          PROGRESS = ':foreground #C0A1F0 :weight bold',
          DONE = ':foreground #B1D99C :weight bold :slant italic',
          WAITING = ':foreground #EAAC86 :weight bold :slant italic',
          CANCELLED = ':foreground #C7CFF2 :weight bold :slant italic',
          MEETING = ':foreground #89dceb :weight bold',
        },
        mappings = {
          capture = {
            org_capture_refile = 'R',
            org_capture_kill = 'Q'
          },
          org = {
            org_refile = 'R',
          },
        },
        calendar_week_start_day = 0,
        win_split_mode = function(name)
          local bufnr = vim.api.nvim_create_buf(false, true)
          --- Setting buffer name is required
          vim.api.nvim_buf_set_name(bufnr, name)

          local fill = 0.8
          local width = math.floor((vim.o.columns * fill))
          local height = math.floor((vim.o.lines * fill))
          local row = math.floor((((vim.o.lines - height) / 2) - 1))
          local col = math.floor(((vim.o.columns - width) / 2))

          vim.api.nvim_open_win(bufnr, true, {
            relative = "editor",
            width = width,
            height = height,
            row = row,
            col = col,
            style = "minimal",
            border = "rounded"
          })
        end
      })
    end
  },

  {
    'akinsho/org-bullets.nvim',
    event = 'VeryLazy',
    config = function()
      require('org-bullets').setup()
    end
  },

  {
    {
      'andreadev-it/orgmode-multi-key',
      event = "VeryLazy",
      config = function()
        require('orgmode-multi-key').setup()
      end
    }
  },

  {
    "nvim-neorg/neorg",
    lazy = false,
    build = ":Neorg sync-parsers",
    opts = {
      load = {
        ["core.defaults"] = {}, -- Loads default behaviour
        ["core.concealer"] = {}, -- Adds pretty icons to your documents
        ["core.esupports.metagen"] = {
          config = {
            type = "auto",
          },
        },
        ["core.journal"] = {
          config = {
            journal_folder = "journal",
            strategy = "flat",
            -- toc_format = function()
            --   return { "yy", "mm", "dd", "link", "title" }
            -- end,
            use_template = false,
            workspace = "personal"
          },
        },
        ["core.summary"] = {
          config = {
            strategy = "metagen",
          },
        },
        ["core.keybinds"] = {
          config = {
            neorg_leader = ",",
            hook = function (keybinds)
              keybinds.unmap("norg", "i", "<TAB>")
              keybinds.remap_event("norg", "i", "<M-a>", "core.itero.next-iteration")

              -- Mapping for the journal module
              keybinds.map("norg", "n", ",ot", "<cmd>Neorg journal today<CR>") -- open journal on today
              keybinds.map("norg", "n", ",oy", "<cmd>Neorg journal yesterday<CR>") -- open journal on yesterday
              keybinds.map("norg", "n", ",om", "<cmd>Neorg journal tomorrow<CR>") -- open journal on tomorrow
              keybinds.map("norg", "n", ",oj", "<cmd>Neorg journal toc open<CR>") -- open journal toc
              keybinds.map("norg", "n", ",uj", "<cmd>Neorg journal toc update<CR>") -- update journal toc

              -- Mapping for Neorg Telescope plugin
              keybinds.map("norg", "n", ",fw", "<cmd>Telescope neorg find_linkable<CR>") -- find linkable items with telescope
              keybinds.map("norg", "n", ",ff", "<cmd>Telescope neorg find_neorg_files<CR>") -- find neorg files with telescope
              keybinds.map("norg", "n", ",ww", "<cmd>Telescope neorg switch_workspace<CR>") -- switch to neorg workspace with telescope
              keybinds.map("norg", "i", "<C-i>", "<cmd>Telescope neorg insert_link<CR>") -- find and insert link with telescope

              local neorg_callbacks = require("neorg.callbacks")

              neorg_callbacks.on_event("core.keybinds.events.enable_keybinds", function(_, keys)
                -- Map all the below keybinds only when the "norg" mode is active
                keys.map_event_to_mode("norg", {
                  n = { -- Bind keys in normal mode
                    -- { "<C-s>", "core.integrations.telescope.find_linkable" },
                  },

                  i = { -- Bind in insert mode
                    -- { "<M-n>", "core.integrations.telescope.insert_link" },
                    { "<TAB>", "" },
                  },
                }, {
                    silent = true,
                    noremap = true,
                  })
              end)
            end,
          },
        }, -- Adds pretty icons to your documents
        ["core.integrations.telescope"] = {},
        ["core.dirman"] = { -- Manages Neorg workspaces
          config = {
            workspaces = {
              notes = "~/notes",
              projects = "~/projects",
              personal = "~/personal",
              work_log = "~/work_log"
            },
            default_workspace = 'work_log'
          },
        },
      },
    },
    dependencies = { { "nvim-lua/plenary.nvim" }, { "nvim-neorg/neorg-telescope" }  },
  },

  {
    "jcdickinson/codeium.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      require("codeium").setup({
      })
    end
  },

  {
    "aaditeynair/conduct.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
      require("telescope").load_extension("conduct")
      require("conduct").setup({
        -- define function that you bind to a key in a project config
        functions = {},

        -- define presets for projects
        presets = {},

        hooks = {
          before_session_save = function() end,
          before_session_load = function() end,
          after_session_load = function() end,
          before_project_load = function() end,
          after_project_load = function()
            local current_buf = vim.api.nvim_get_current_buf()
            local current_buf_dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(current_buf), ':p:h')
            local current_project_root = vim.fn.finddir('.git', current_buf_dir .. ';')
            if current_project_root == '' then
              print('No project root found for current buffer')
              return
            end
            current_project_root = vim.fn.fnamemodify(current_project_root, ':h')

            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              local buf_dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ':p:h')
              local buf_project_root = vim.fn.finddir('.git', buf_dir .. ';')
              if buf_project_root == '' or vim.fn.fnamemodify(buf_project_root, ':h') ~= current_project_root then
                vim.api.nvim_buf_delete(buf, { force = true })
              end
            end
          end,
        }
      })
      -- optional: vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>")
    end,
    cmd = {
      "ConductNewProject",
      "ConductLoadProject",
      "ConductLoadLastProject",
      "ConductLoadProjectConfig",
      "ConductReloadProjectConfig",
      "ConductDeleteProject",
      "ConductRenameProject",
      "ConductProjectNewSession",
      "ConductProjectLoadSession",
      "ConductProjectDeleteSession",
      "ConductProjectRenameSession",
    },
  },


  -- Creates a db of my yank history
  {
    "AckslD/nvim-neoclip.lua",
    lazy = false,
    requires = {
      {'kkharji/sqlite.lua', module = 'sqlite'},
      {'nvim-telescope/telescope.nvim'},
    },
    config = function()
      require('neoclip').setup()
      require('telescope').load_extension('neoclip')
    end,
    opts = {
      history = 1000,
      enable_persistent_history = true,
      length_limit = 1048576,
      continuous_sync = true,
      db_path = vim.fn.stdpath("data") .. "/databases/neoclip.sqlite3",
      filter = nil,
      preview = true,
      prompt = nil,
      default_register = '"',
      default_register_macros = 'q',
      enable_macro_history = true,
      content_spec_column = false,
      on_select = {
        move_to_front = true,
        close_telescope = true,
      },
      on_paste = {
        set_reg = false,
        move_to_front = false,
        close_telescope = true,
      },
      on_replay = {
        set_reg = false,
        move_to_front = false,
        close_telescope = true,
      },
      on_custom_action = {
        close_telescope = true,
      },
      keys = {
        telescope = {
          i = {
            select = '<cr>',
            paste = '<c-p>',
            paste_behind = '<c-k>',
            replay = '<c-q>',  -- replay a macro
            delete = '<c-d>',  -- delete an entry
            edit = '<c-e>',  -- edit an entry
            custom = {},
          },
          n = {
            select = '<cr>',
            paste = 'p',
            --- It is possible to map to more than one key.
            -- paste = { 'p', '<c-p>' },
            paste_behind = 'P',
            replay = 'q',
            delete = 'd',
            edit = 'e',
            custom = {},
          },
        },
        fzf = {
          select = 'default',
          paste = 'ctrl-p',
          paste_behind = 'ctrl-k',
          custom = {},
        },
      },
    }
  },

  {
    "simrat39/symbols-outline.nvim",
    event = "VeryLazy",
    config = function()
      require("symbols-outline").setup()
    end
  },

  {
    'pangloss/vim-javascript',
    event = "VeryLazy",
    lazy = false
  },
  {
    'leafgarland/typescript-vim',
    event = "VeryLazy",
    lazy = false

  },
  {
    'peitalin/vim-jsx-typescript' ,
    event = "VeryLazy",
    lazy = false

  },
  {
    'MaxMEllon/vim-jsx-pretty' ,
    event = "VeryLazy",
    lazy = false

  },
  {
    'neoclide/vim-jsx-improve' ,
    event = "VeryLazy",
    lazy = false

  },

  {
    "sindrets/diffview.nvim",
    event = "VeryLazy",
    lazy = false,
    config = function()
      require("diffview").setup({
        enhanced_diff_hl = false,
        file_panel = {
          listing_style = "list"
        }
      })
    end
  },

  {
    "NeogitOrg/neogit",
    event = "VeryLazy",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",         -- required
      "nvim-telescope/telescope.nvim", -- optional
      "sindrets/diffview.nvim",        -- optional
    },
    config = true
  },

  {
    "FabijanZulj/blame.nvim",
    event = "VeryLazy",
    lazy = false
  }
  -- {
  --   "folke/edgy.nvim",
  --   event = "VeryLazy",
  --   keys = {
  --     -- stylua: ignore
  --     { "<leader>ue", function() require("edgy").select() end, desc = "Edgy Select Window" },
  --   },
  --   opts = {
  --     left = {
  --       -- {
  --       --   title = "Neo-Tree",
  --       --   ft = "neo-tree",
  --       --   filter = function(buf)
  --       --     return vim.b[buf].neo_tree_source == "filesystem"
  --       --   end,
  --       --   size = { height = 0.5 },
  --       -- },
  --       -- {
  --       --   title = "Neo-Tree Git",
  --       --   ft = "neo-tree",
  --       --   filter = function(buf)
  --       --     return vim.b[buf].neo_tree_source == "git_status"
  --       --   end,
  --       --   pinned = true,
  --       --   open = "Neotree position=right git_status",
  --       -- },
  --       -- {
  --       --   title = "Neo-Tree Buffers",
  --       --   ft = "neo-tree",
  --       --   filter = function(buf)
  --       --     return vim.b[buf].neo_tree_source == "buffers"
  --       --   end,
  --       --   pinned = true,
  --       --   open = "Neotree position=top buffers",
  --       -- },
  --       {
  --         ft = "Outline",
  --         pinned = true,
  --         open = "SymbolsOutline",
  --       },
  --       -- "neo-tree",
  --     },
  --   },
  -- }


  -- To make a plugin not be loaded

  -- All NvChad plugins are lazy-loaded by default
  -- For a plugin to be loaded, you will need to set either `ft`, `cmd`, `keys`, `event`, or set `lazy = false`
  -- If you want a plugin to load on startup, add `lazy = false` to a plugin spec, for example
  -- {
  --   "mg979/vim-visual-multi",
  --   lazy = false,
  -- }
}

return plugins
