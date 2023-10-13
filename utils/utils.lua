local uv = vim.loop
local path_sep = uv.os_uname().version:match("Windows") and "\\" or "/"
local fn, api, cmd, diag, o, g, tbl_contains, bo, keymap =
	vim.fn, vim.api, vim.cmd, vim.diagnostic, vim.o, vim.g, vim.tbl_contains, vim.bo, vim.keymap

local M = {}

--- assert that the given argument is in fact of the correct type.
---
--- Thanks!!
--- https://github.com/lunarmodules/Penlight
---
-- @param n argument index
-- @param val the value
-- @param tp the type
-- @param verify an optional verification function
-- @param msg an optional custom message
-- @param lev optional stack position for trace, default 2
-- @return the validated value
-- @raise if `val` is not the correct type
-- @usage
-- local param1 = assert_arg(1,"hello",'table')  --> error: argument 1 expected a 'table', got a 'string'
-- local param4 = assert_arg(4,'!@#$%^&*','string',path.isdir,'not a directory')
--      --> error: argument 4: '!@#$%^&*' not a directory
function M.assert_arg(n, val, tp, verify, msg, lev)
	if type(val) ~= tp then
		error(("argument %d expected a '%s', got a '%s'"):format(n, tp, type(val)), lev or 2)
	end
	if verify and not verify(val) then
		error(("argument %d: '%s' %s"):format(n, val, msg), lev or 2)
	end
	return val
end

--- Thanks!!
--- https://github.com/lunarmodules/Penlight
local function assert_string(n, s)
	M.assert_arg(n, s, "string")
end

--- Check if a plugin is defined in lazy. Useful with lazy loading when a plugin is not necessarily loaded yet
---@param plugin string # The plugin to search for
---@return boolean available # Whether the plugin is available
function M.is_available(plugin)
	local lazy_config_avail, lazy_config = pcall(require, "lazy.core.config")
	return lazy_config_avail and lazy_config.plugins[plugin] ~= nil
end

--- Call function if a condition is met
---@param func function # The function to run
---@param condition boolean # Wether to run the function or not
---@return any|nil result # The result of the function running or nil
function M.conditional_func(func, condition, ...)
	if condition and type(func) == "function" then
		return func(...)
	end
end

--- Check if a list of strings has a value
--- @param options string[] # The list of strings to check
--- @param val string # The value to check
function M.has_value(options, val)
	for _, value in ipairs(options) do
		if value == val then
			return true
		end
	end

	return false
end

--- Checks whether a given path exists and is a directory
--- Thanks LunarVim!
--@param path (string) path to check
--@returns (bool)
function M.is_directory(path)
	local stat = uv.fs_stat(path)
	return stat and stat.type == "directory" or false
end

--- Thanks LunarVim!
---Join path segments that were passed as input
---@return string
function M.join_paths(...)
	local result = table.concat({ ... }, path_sep)
	return result
end

local ellipsis = "..."
local n_ellipsis = #ellipsis

--- Return a shortened version of a string.
--- Fits string within w characters. Removed characters are marked with ellipsis.
---
--- Thanks!!
--- https://github.com/lunarmodules/Penlight
---
-- @string s the string
-- @int w the maxinum size allowed
-- @bool tail true if we want to show the end of the string (head otherwise)
-- @usage ('1234567890'):shorten(8) == '12345...'
-- @usage ('1234567890'):shorten(8, true) == '...67890'
-- @usage ('1234567890'):shorten(20) == '1234567890'
function M.shorten(s, w, tail)
	assert_string(1, s)
	if #s > w then
		if w < n_ellipsis then
			return ellipsis:sub(1, w)
		end
		if tail then
			local i = #s - w + 1 + n_ellipsis
			return ellipsis .. s:sub(i)
		else
			return s:sub(1, w - n_ellipsis) .. ellipsis
		end
	end
	return s
end

M.cmd_map = function(lhs, rhs, modes, opts)
	modes = M.str_to_tbl(modes) or { "n" }
	opts = opts or { silent = true, noremap = true }
	for _, mode in ipairs(modes) do
		keymap.set(mode, lhs, M.cmd_string(rhs), opts)
	end
end

M.func_map = function(lhs, rhs, modes, opts)
	modes = M.str_to_tbl(modes) or { "n" }
	opts = opts or { silent = true, noremap = true }
	for _, mode in ipairs(modes) do
		keymap.set(mode, lhs, rhs, opts)
	end
end

M.cmd_string = function(cmd_arg)
	return [[<cmd>]] .. cmd_arg .. [[<cr>]]
end

M.lazy_map = function(lhs, rhs, modes)
	modes = M.str_to_tbl(modes) or { "n" }
	return {
		lhs,
		M.cmd_string(rhs),
		mode = modes,
	}
end

M.create_augroup = function(group, opts)
	opts = opts or { clear = true }
	return api.nvim_create_augroup(group, opts)
end

M.nonrelative_win_count = function()
	local wins = api.nvim_list_wins()
	local non_relative = 0
	for _, win in ipairs(wins) do
		local config = api.nvim_win_get_config(win)
		if config.relative == "" then
			non_relative = non_relative + 1
		end
	end
	return non_relative
end

M.current_word = function()
	local current_word = fn.expand("<cword>")
	return current_word
end

M.str_to_tbl = function(v)
	if type(v) == "string" then
		v = { v }
	end
	return v
end

M.tbl_index = function(tbl, value)
	for i, v in ipairs(tbl) do
		if v == value then
			return i
		end
	end
	return nil
end

M.tbl_foreach = function(tbl, f)
	local t = {}
	for key, value in ipairs(tbl) do
		t[key] = f(value)
	end
	return t
end

M.tbl_filter = function(tbl, f)
	if not tbl or tbl == {} then
		return {}
	end
	local t = {}
	for key, value in ipairs(tbl) do
		if f(key, value) then
			table.insert(t, value)
		end
	end
	return t
end

M.list_concat = function(A, B)
	local t = {}
	for _, value in ipairs(A) do
		table.insert(t, value)
	end
	for _, value in ipairs(B) do
		table.insert(t, value)
	end
	return t
end

M.tbl_system_cmd = function(command)
	local stdout = {}
	local handle = io.popen(command .. " 2>&1 ; echo $?", "r")
	if handle then
		for line in handle:lines() do
			stdout[#stdout + 1] = line
		end
		stdout[#stdout] = nil
		handle:close()
	end
	return stdout
end

M.map_q_to_quit = function(event)
	bo[event.buf].buflisted = false
	M.cmd_map("q", "close", "n", { silent = true, noremap = true, buffer = true })
end

M.is_qf_empty = function()
	return vim.tbl_isempty(fn.getqflist())
end

local is_lsp_diag_error = function()
	return #diag.get(0, { severity = diag.severity.ERROR }) > 0
end
local is_lsp_diag_warning = function()
	return #diag.get(0, { severity = diag.severity.WARN }) > 0
end
local is_lsp_diag_info = function()
	return #diag.get(0, { severity = diag.severity.INFO }) > 0
end

M.lsp_diag = function(level)
	if level == "error" then
		return is_lsp_diag_error()
	elseif level == "warning" then
		return is_lsp_diag_warning()
	elseif level == "info" then
		return is_lsp_diag_info()
	end
end

M.restore_cmdheight = function()
	if g.CMDHEIGHTZERO == 1 then
		o.cmdheight = 0
	else
		o.cmdheight = 1
	end
end

M.create_cmd = function(command, f, opts)
	opts = opts or {}
	api.nvim_create_user_command(command, f, opts)
end

M.screen_scale = function(config)
	local defaults = {
		width = 0.5,
		height = 0.5,
	}
	config = config or defaults
	config.width = config.width or defaults.width
	config.height = config.height or defaults.height
	local width = fn.round(o.columns * config.width)
	local height = fn.round(o.lines * config.height)
	return width, height
end

M.load_configs = function()
	for _, file in ipairs(M.get_config_modules()) do
		require("config." .. file)
	end
	require("config.lazy")
end

M.get_config_modules = function(exclude_map)
	exclude_map = exclude_map or {
		"lazy",
		"init",
		"statuscol",
	}
	local files = {}
	for _, file in ipairs(fn.glob(fn.stdpath("config") .. "/lua/config/*.lua", true, true)) do
		table.insert(files, fn.fnamemodify(file, ":t:r"))
	end
	files = vim.tbl_filter(function(file)
		for _, pattern in ipairs(exclude_map) do
			if file:match(pattern) then
				return false
			end
		end
		return true
	end, files)
	return files
end

M.reload_lua = function()
	for _, file in ipairs(M.get_config_modules()) do
		R("config." .. file)
	end
	cmd.nohlsearch()
end

M.diag_error = function()
	return #diag.get(0, { severity = diag.severity.ERROR }) ~= 0
end

M.treesitter_is_css_class_under_cursor = function()
	local ft = bo.filetype
	if not tbl_contains({ "typescript", "typescriptreact", "vue", "html", "svelt", "astro" }, ft) then
		return false
	end
	local ft_query = [[
    (attribute
      (attribute_name) @attr_name
        (quoted_attribute_value (attribute_value) @attr_val)
        (#match? @attr_name "class")
    )
    ]]
	local queries = vim.treesitter.query.parse(ft, ft_query)
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor = vim.treesitter.get_node({
		bufnr = bufnr,
		ignore_injections = false,
	})
	if cursor == nil then
		return false
	end
	local parent = cursor:parent()

	if not parent then
		return false
	end

	if queries == nil then
		return false
	end

	for id, _ in queries:iter_captures(parent, bufnr, 0, -1) do
		local name = queries.captures[id]
		return #name > 0
	end
end

M.hover_handler = function()
	local winid = require("ufo").peekFoldedLinesUnderCursor()
	if winid then
		return
	end
	local ft = bo.filetype
	if tbl_contains({ "vim", "help" }, ft) then
		cmd("silent! h " .. fn.expand("<cword>"))
	elseif M.treesitter_is_css_class_under_cursor() then
		cmd("TWValues")
	elseif tbl_contains({ "man" }, ft) then
		cmd("silent! Man " .. fn.expand("<cword>"))
	elseif fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
		require("crates").show_popup()
	else
		vim.lsp.buf.hover()
	end
end

M.is_x_display = function()
	local x_display = os.getenv("DISPLAY")
	return x_display ~= nil and x_display ~= ""
end

return M
