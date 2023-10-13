local fn, cmd, api, o, g, ui = vim.fn, vim.cmd, vim.api, vim.o, vim.g, vim.ui
local set_cur = api.nvim_win_set_cursor
local u = require("custom.utils")
local ufo = require("custom.utils.ufo")

local M = {}

M.telescope_fd_opts = function(opts)
	opts = opts or {}
	cmd([[lua require('telescope.builtin').fd(opts)]])
end

M.telescope_find_files_cwd = function()
	M.telescope_fd_opts({ search_dirs = { fn.expand("%:h") } })
end

M.telescope_find_files_no_ignore = function()
	M.telescope_fd_opts({ no_ignore = true })
end

M.comment_yank_paste = function()
	local win = api.nvim_get_current_win()
	local cur = api.nvim_win_get_cursor(win)
	local vstart = fn.getpos("v")[2]
	local current_line = fn.line(".")
	if vstart == current_line then
		cmd.yank()
		require("Comment.api").toggle.linewise.current()
		cmd.put()
		set_cur(win, { cur[1] + 1, cur[2] })
	else
		if vstart < current_line then
			cmd(":" .. vstart .. "," .. current_line .. "y")
			cmd.put()
			set_cur(win, { fn.line("."), cur[2] })
		else
			cmd(":" .. current_line .. "," .. vstart .. "y")
			set_cur(win, { vstart, cur[2] })
			cmd.put()
			set_cur(win, { fn.line("."), cur[2] })
		end
		require("Comment.api").toggle.linewise(fn.visualmode())
	end
end

M.buf_only_window_only = function()
	if #api.nvim_list_wins() > 1 then
		cmd.only()
	end
	cmd.BufOnly()
end

M.toggle_cmdheight = function()
	if o.cmdheight == 1 then
		o.cmdheight = 0
		g.CMDHEIGHTZERO = 1
	else
		o.cmdheight = 1
		g.CMDHEIGHTZERO = 0
	end
end

M.run_system_command = function(config)
	if not config or not config.cmd then
		return
	end
	vim.defer_fn(function()
		local handle = io.popen(config.cmd)
		if handle then
			local result = handle:read("*a")
			handle:close()
			if config.notify == true then
				config.title = config.title or "System Command"
				require("notify").notify(result, vim.log.levels.INFO, {
					title = config.title,
				})
			end
		end
	end, 0)
end

M.load_previous_buffer = function()
	if #fn.expand("#") > 0 then
		cmd.edit(fn.expand("#"))
	end
end

M.populate_qf = function(lines, mode)
	if mode == nil or type(mode) == "table" then
		lines = u.tbl_foreach(lines, function(item)
			return { filename = item, lnum = 1, col = 1, text = item }
		end)
		mode = "r"
	end
	fn.setqflist(lines, mode)
	cmd.cwindow()
	cmd([[wincmd p]])
end

local open_help_tab = function(help_cmd, topic)
	cmd.tabe()
	local winnr = api.nvim_get_current_win()
	cmd(help_cmd .. " " .. topic)
	api.nvim_win_close(winnr, false)
end

M.help_select = function()
	ui.input({ prompt = "Open help for> " }, function(input)
		if not input then
			return
		end
		open_help_tab("help", input)
	end)
end

M.help_word = function()
	local current_word = u.current_word()
	open_help_tab("help", current_word)
end

M.help_grep = function()
	ui.input({ prompt = "Grep help for: " }, function(input)
		if input == "" then
			return
		end
		open_help_tab("helpgrep", input)
		cmd.copen()
	end)
end

M.tagstack_navigate = function(config)
	if not config or not config.direction then
		return
	end
	local direction = config.direction
	local tagstack = fn.gettagstack()
	if tagstack == nil or tagstack.items == nil or #tagstack.items == 0 then
		return
	end
	if direction == "up" then
		if tagstack.curidx > tagstack.length then
			return
		end
		cmd.tag()
	end
	if direction == "down" then
		if tagstack.curidx == 1 then
			return
		end
		cmd.pop()
	end
end

M.wilder_update_remote_plugins = function()
	local update = function()
		cmd([[silent! UpdateRemotePlugins]])
	end
	local rplugin = fn.stdpath("data") .. "/rplugin.vim"
	if fn.filereadable(rplugin) ~= 1 then
		update()
		return
	end
	local wilder_updated = false
	for _, line in ipairs(fn.readfile(rplugin)) do
		if line:match("wilder#lua#remote#host") then
			wilder_updated = true
			break
		end
	end
	if not wilder_updated then
		update()
		return
	end
end

M.spectre_open = function()
	cmd([[lua require("spectre").open()]])
end

M.spectre_open_word = function()
	cmd([[lua require("spectre").open_visual({select_word = true})]])
end

M.spectre_open_cwd = function()
	cmd([[lua require("spectre").open_file_search()]])
end

M.reload_dev = function()
	u.reload_dev()
end

M.reload_lua = function()
	u.reload_lua()
end

M.update_all = function()
	local cmds = {
		"MasonToolsUpdate",
		"TSUpdate",
		"Lazy sync",
	}
	for _, c in ipairs(cmds) do
		print("Running: " .. c)
		cmd(c)
	end
end

M.ufo_toggle_fold = function()
	return ufo.toggle_fold()
end

M.fold_paragraph = function()
  print("test herer")
	local foldclosed = fn.foldclosed(fn.line("."))
	if foldclosed == -1 then
		cmd([[silent! normal! zfip]])
	else
		cmd("silent! normal! zo")
	end
end

M.make_run = function()
	if M.terminal_send_cmd("") then
		local file_name = fn.expand("%:t:r")
		M.terminal_send_cmd("make " .. file_name)
		M.terminal_send_cmd("clear && ./" .. file_name)
	else
		cmd.make([[%<]])
		cmd([[!./%<]])
		cmd.cwindow()
	end
end

u.create_augroup("MakeOnSave")
M.auto_make_toggle = function()
	local autocmds = api.nvim_get_autocmds({ group = "MakeOnSave" })
	if #autocmds > 0 then
		u.create_augroup("MakeOnSave")
	else
		local make_on_save = u.create_augroup("MakeOnSave")
		api.nvim_create_autocmd({ "BufWritePost" }, {
			group = make_on_save,
			pattern = { "*.cpp" },
			callback = function()
				M.make_run()
			end,
		})
	end
end

M.terminal_send_cmd = function(cmd_text)
	local function get_first_terminal()
		local terminal_chans = {}
		for _, chan in pairs(api.nvim_list_chans()) do
			if chan["mode"] == "terminal" and chan["pty"] ~= "" then
				table.insert(terminal_chans, chan)
			end
		end
		table.sort(terminal_chans, function(left, right)
			return left["buffer"] < right["buffer"]
		end)
		if #terminal_chans == 0 then
			return nil
		end
		return terminal_chans[1]["id"]
	end

	local send_to_terminal = function(terminal_chan, term_cmd_text)
		api.nvim_chan_send(terminal_chan, term_cmd_text .. "\n")
	end

	local terminal = get_first_terminal()
	if not terminal then
		return nil
	end

	if not cmd_text then
		ui.input({ prompt = "Send to terminal: " }, function(input_cmd_text)
			if not input_cmd_text then
				return nil
			end
			send_to_terminal(terminal, input_cmd_text)
		end)
	else
		send_to_terminal(terminal, cmd_text)
	end
	return true
end

M.terminal_open_split = function(cfg)
	local defaults = {
		direction = "right",
		scale = nil,
		tab = false,
	}
	cfg = vim.tbl_extend("keep", cfg, defaults)
	if cfg.tab == false then
		if cfg.direction == "right" then
			cmd.FocusSplitRight()
		else
			cmd.FocusSplitDown()
		end
	else
		cmd.tabe()
		cmd.terminal()
		return
	end
	cmd.terminal()
	if cfg.scale then
		local winnr = api.nvim_get_current_win()
		if cfg.direction == "right" then
			api.nvim_win_set_width(winnr, math.floor(o.columns * cfg.scale))
		else
			api.nvim_win_set_height(winnr, math.floor(o.lines * cfg.scale))
		end
	end
end

return M
