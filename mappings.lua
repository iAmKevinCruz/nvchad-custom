---@type MappingsTable
local M = {}

-- In order to disable a default keymap, use
M.disabled = {
  n = {
      ["s"] = "",
      ["S"] = "",
      ["<C-c>"] = "",
      ["<M-i>"] = "",
      ["<A-i>"] = "",
      ["<leader>b"] = "",
      [";"] = "",
  },
  v = {
      ["J"] = "",
      ["K"] = ""
  },
}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
    ["<C-d>"] = { "<C-d>zz", "Scroll down and center cursor" },
    ["<C-u>"] = { "<C-u>zz", "Scroll up and center cursor" },
    ["<leader>q"] = { ":q <CR>", "Exit (q) buffer" },
    ["<Leader>to"] = {"<CMD>tabnew<CR>","Create new tab"},
    ["<Leader>tx"] = {"<CMD>tabclose<CR>","Close tab"},
    ["<A-.>"] = {"<CMD>tabn<CR>","Next tab"},
    ["<A-,>"] = {"<CMD>tabp<CR>","Prev tab"},
    ["<A->>"] = { ":+tabmove<CR>", "Move tab to the right" },
    ["<A-<>"] = { ":-tabmove<CR>", "Move tab to the left" },
    ["x"] = {'"_x', "Delete without yanking"},
    ["<leader>d"] = {[["_d]], "Delete without yanking"},
    ["<leader>p"] = {[["_dP]], "Delete without yanking"},
    ["<M-c>"] = {[["+y]], "Yank to system clipboard"},
    ["<leader>y"] = {[["+y]], "Yank to system clipboard"},
    -- ["<C-c>"] = {"<ESC>", "Escape btn with <C>"},
    ["<M-b>"] = {"<CMD>lua require('base46').toggle_transparency()<CR>","Toggle Transparency"},
    ["={"] = {"=a{","Format space AROUND curly braces"},
    ["=}"] = {"=i{","Format space INSIDE curly braces"},
    ["=("] = {"=a(","Format space AROUND parentheses"},
    ["=)"] = {"=i(","Format space INSIDE parentheses"},
    ["=["] = {"=a[","Format space AROUND brackets"},
    ["=]"] = {"=i]","Format space INSIDE brackets"},
    ["<leader>x"] = {":bd<CR>","Buffer delete"},
    ["<leader>b"] = {":lua require('telescope.builtin').buffers({sort_mru=true})<CR>","Telescope recent and last buffer search", opts = { silent = true }},
  },
  v = {
    ["J"] = {":m '>+1<CR>gv=gv", "Move line down"},
    ["K"] = {":m '<-2<CR>gv=gv", "Move line up"},
    ["<M-c>"] = {[["+y]], "Yank to system clipboard"},
    ["x"] = {'"_x', "Delete without yanking"},
    ["<leader>U"] = {':s/\\%V\\w\\+/\\u&/g<CR>', "Capitalize words in selection" },
  },
  i = {
    ["<M-BS>"] = {"<ESC>vbc","Delete word"},
  },
  x = {
  }
}

M.neogit = {
  n = {
    ["<leader>nn"] = { "<CMD>Neogit<CR>", "Open Neogit in new tab", opts = { silent = true } },
  }
}

M.buffer_manager = {
  n = {
    ["<M-Space>"] = { ":lua require('buffer_manager.ui').toggle_quick_menu()<CR>", "Toggle buffer quick menu", opts = { silent = true } },
    ["<TAB>"] = { ":lua require('buffer_manager.ui').nav_next()<CR>", "Buffer next", opts = { silent = true } },
    ["<S-TAB>"] = { ":lua require('buffer_manager.ui').nav_prev()<CR>", "Buffer prev", opts = { silent = true } },
  }
}

M.truezen = {
  n = {
    ["<leader>zn"] = { ":TZNarrow<CR>", "Truezen Narrow Mode", opts = { silent = true } },
    ["<leader>zf"] = { ":TZFocus<CR>", "Truezen Focus Mode", opts = { silent = true } },
    ["<leader>zm"] = { ":TZMinimalist<CR>", "Truezen Minimalist Mode", opts = { silent = true } },
    ["<leader>za"] = { ":TZAtaraxis<CR>", "Truezen Ataraxis Mode", opts = { silent = true } },
  },
  v = {
    ["<leader>zn"] = { ":'<,'>tznarrow<cr>", "truezen narrow mode", opts = { silent = true } },
  }
}

M.specs = {
  n = {
    ["n"] = { "n:lua require('specs').show_specs()<CR>", "Next + Specs cursor beacon", opts = { noremap = true, silent = true } },
    ["N"] = { "N:lua require('specs').show_specs()<CR>", "Prev + Specs cursor beacon", opts = { noremap = true, silent = true } },
  }
}

M.neoclip = {
  n = {
    ["<leader>yh"] = { ":Telescope neoclip <CR>", "Open Yank History with neoclip"},
  }
}

M.symbol_outline = {
  n = {
    ["<leader>so"] = { "<cmd>SymbolsOutline<CR>", "Open Symbols Outline"},
  }
}

M.blame = {
  n = {
    ["<leader>tbw"] = { ":ToggleBlame window<CR>", "Toggle blame window" },
    ["<leader>tbv"] = { ":ToggleBlame virtual<CR>", "Toggle blame virtual text" },
  }
}

M.git_worktree = {
  n = {
    ["<leader>gw"] = { ":lua require('telescope').extensions.git_worktree.git_worktrees()<CR>", "Open Git-Worktrees via Telescope", opts = { silent = true } },
    ["<leader>gW"] = { ":lua require('telescope').extensions.git_worktree.create_git_worktree()<CR>", "Create new Git Worktree via Telescope", opts = { silent = true } },
  }
}

M.neorg = {
  n = {
    ["<leader>ni"] = { ":Neorg index<CR>", "Open Neorg Index File" },
    ["<leader>nr"] = { ":Neorg return<CR>", "Close all Neorg files" },
    ["<leader>ot"] = { "<cmd>Neorg journal today<cr>", "Open Neorg Today's Journal Note"},
    ["<leader>oy"] = { "<cmd>Neorg journal yesterday<cr>", "Open Neorg Yesterday's Journal Note"},
  }
}

M.orgmode = {
  n = {
    ["<leader>of"] = { ":Telescope orgmode search_headings<CR>", "Open Telescope for OrgMode headings", opts = { silent = true } },
    ["<leader>ov"] = { ":Telescope orgmode refile_heading<CR>", "Open Telescope to refile OrgMode heading", opts = { silent = true } },
  }
}

M.lazygit = {
  n = {
    ["<leader>gg"] = { ":LazyGit <CR>", "Open floating LazyGit"},
    ["<leader>gf"] = { ":LazyGitFilter <CR>", "Open floating LazyGitFilter to see all commits"},
  }
}

M.telescope = {
  n = {
    ["<leader>fqq"] = { "<cmd>Telescope quickfix<cr>", "Open Telescope Quickfix" },
    ["<leader>fq"] = { "<cmd>Telescope quickfixhistory<cr>", "Open Telescope Quickfix History" },
    -- ["<C-c>"] = { "<ESC>", "telescope close" },
  }
}

M.telescope_undo = {
  n = {
    ["<leader>u"] = { "<cmd>Telescope undo<cr>", "Open Telescope Undo"},
  }
}

M.undotree = {
  n = {
    ["<leader>ut"] = { "<cmd>UndotreeToggle<cr><cmd>UndotreeFocus<cr>", "Open Undotree"},
  }
}

M.conduct = {
  n = {
    ["<leader>cop"] = { "<cmd>Telescope conduct projects<cr>", "Open Conduct Projects with Telescope"},
    ["<leader>cos"] = { "<cmd>Telescope conduct sessions<cr>", "Open Conduct Sessions with Telescope"},
  }
}

M.oil = {
  n = {
    ["<leader>-"] = { "<cmd>Oil<cr>", "Open Oil directory editor" },
  }
}

M.harpoon = {
  n = {
    ["<leader>gh"] = { ':Telescope harpoon marks<cr>', "Telescope harpoon files" },
    ["gh"] = { ':lua require("harpoon.ui").toggle_quick_menu()<cr>', "Open harpoon file menu", opts = { silent = true } },
    ["gH"] = { ':lua require("harpoon.mark").add_file()<cr>', "Add file to harpoon", opts = { silent = true } },
    ["g>"] = { ':lua require("harpoon.ui").nav_next()<cr>', "Next harpoon file", opts = { silent = true } },
    ["g<"] = { ':lua require("harpoon.ui").nav_prev()<cr>', "Prev harpoon file", opts = { silent = true } },
    ["<M-l>"] = { ':lua require("harpoon.ui").nav_file(1)<cr>', "Open harpoon file 1", opts = { silent = true } },
    ["<M-u>"] = { ':lua require("harpoon.ui").nav_file(2)<cr>', "Open harpoon file 2", opts = { silent = true } },
    ["<M-y>"] = { ':lua require("harpoon.ui").nav_file(3)<cr>', "Open harpoon file 3", opts = { silent = true } },
    ["<M-;>"] = { ':lua require("harpoon.ui").nav_file(4)<cr>', "Open harpoon file 4", opts = { silent = true } },
    ["<M-1>"] = { ':lua require("harpoon.ui").nav_file(1)<cr>', "Open harpoon file 1", opts = { silent = true } },
    ["<M-2>"] = { ':lua require("harpoon.ui").nav_file(2)<cr>', "Open harpoon file 2", opts = { silent = true } },
    ["<M-3>"] = { ':lua require("harpoon.ui").nav_file(3)<cr>', "Open harpoon file 3", opts = { silent = true } },
    ["<M-4>"] = { ':lua require("harpoon.ui").nav_file(4)<cr>', "Open harpoon file 4", opts = { silent = true } },
    ["<M-5>"] = { ':lua require("harpoon.ui").nav_file(5)<cr>', "Open harpoon file 5", opts = { silent = true } },
    ["<M-6>"] = { ':lua require("harpoon.ui").nav_file(6)<cr>', "Open harpoon file 6", opts = { silent = true } },
    ["<M-7>"] = { ':lua require("harpoon.ui").nav_file(7)<cr>', "Open harpoon file 7", opts = { silent = true } },
    ["<M-8>"] = { ':lua require("harpoon.ui").nav_file(8)<cr>', "Open harpoon file 8", opts = { silent = true } },
    ["<M-9>"] = { ':lua require("harpoon.ui").nav_file(9)<cr>', "Open harpoon file 9", opts = { silent = true } },
  }
}

M.MiniFiles = {
  n = {
    ["-"] = {':lua require("mini.files").open(vim.api.nvim_buf_get_name(0), true)<CR>', "Open mini.files floating file manager at current directory", opts = { silent = true } },
    ["<leader>fe"] = {':lua require("mini.files").open(vim.loop.cwd(), true)<CR>', "Open mini.files floating file manager at root directory", opts = { silent = true } },
  }
}

M.MiniSession = {
  n = {
    ["<leader>msr"] = {':lua MiniSessions.read()<CR>', "Load MiniSession session", opts = { silent = true } }
  }
}

M.obsidian = {
  n = {
    -- ["<leader>ot"] = { "<cmd>ObsidianToday<cr>", "Open Obsidian Today's Daily Note"},
    -- ["<leader>oT"] = { "<cmd>ObsidianTemplate<cr>", "Open Obsidian Templates"},
    -- ["<leader>oy"] = { "<cmd>ObsidianYesterday<cr>", "Open Obsidian Yesterday's Note"},
    -- ["<leader>of"] = { "<cmd>ObsidianFollowLink<cr>", "Follow Obsidian Link"},
    -- ["<leader>os"] = { "<cmd>ObsidianSearch<cr>", "Search in Obsidian"},
    -- ["<leader>oo"] = { "<cmd>ObsidianOpen<cr>", "Open Obsidian"},
    -- ["<leader>ob"] = { "<cmd>ObsidianBacklinks<cr>", "Open Obsidian Backlinks"},
    -- ["<leader>on"] = { "<cmd>ObsidianNew ", "Create New Obsidian Note"},
    -- ["<leader>om"] = { "<cmd>ObsidianLink<cr>", "Create Obsidian Link"},
    -- ["<leader>ol"] = { "<cmd>ObsidianLinkNew<cr>", "Create New Obsidian Link"},
  }
}


-- more keybinds!

return M
