return {
	"akinsho/toggleterm.nvim",
	event = "VeryLazy",
	config = function()
		local status_ok, toggleterm = pcall(require, "toggleterm")
		if not status_ok then
			return
		end

		toggleterm.setup({
			size = 20,
			open_mapping = [[<c-\>]],
			hide_numbers = true,
			shade_filetypes = {},
			shade_terminals = true,
			shading_factor = 2,
			start_in_insert = true,
			insert_mappings = true,
			persist_size = true,
			direction = "horizontal",
			close_on_exit = true,
			shell = vim.o.shell,
			float_opts = {
				border = "curved",
				winblend = 0,
				highlights = {
					border = "Normal",
					background = "Normal"
				}
			}
		})

		function _G.set_terminal_keymaps()
			local opts = {
				noremap = true
			}
			vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], opts)
			vim.api.nvim_buf_set_keymap(0, "t", "jk", [[<C-\><C-n>]], opts)
			vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
			vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
			vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
			vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
		end

		vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

		local Terminal = require("toggleterm.terminal").Terminal

		-- Try to find the git project root for the current buffer.
		-- This makes Lazygit work nicely even when editing through workspace symlinks.
		local function project_root()
			-- Absolute path to current buffer, or empty string for [No Name]
			local bufname = vim.api.nvim_buf_get_name(0)
			if bufname == "" then
				return vim.loop.cwd()
			end

			-- Start from the directory containing the current file
			local dir = vim.fn.fnamemodify(bufname, ":p:h")
			local prev = ""

			-- Walk up until we find a .git directory or hit filesystem root
			while dir ~= prev do
				if vim.loop.fs_stat(dir .. "/.git") then
					return dir
				end
				prev = dir
				dir = vim.fn.fnamemodify(dir, ":h")
			end

			-- Fallback: behave like before (use Neovim's current working directory)
			return vim.loop.cwd()
		end

		function _LAZYGIT_TOGGLE()
			local root = project_root()

			if vim.env.TMUX then
				-- In tmux, open a popup rooted at the detected project directory.
				-- This keeps the original popup behavior, but makes workspaces + symlinks work.
				local cmd = string.format(
					"tmux display-popup -E -w 95%%%% -h 95%%%% 'cd %s && lazygit'",
					root
				)
				vim.fn.system(cmd)
			else
				local Terminal = require("toggleterm.terminal").Terminal
				local lazygit = Terminal:new({
					cmd = "lazygit",
					dir = root,
					hidden = true,
					direction = "float",
					float_opts = {
						border = "curved",
						winblend = 0,
						width = math.floor(vim.o.columns * 0.9),
						height = math.floor(vim.o.lines * 0.9),
						highlights = {
							border = "Normal",
							background = "Normal"
						}
					},
				})
				lazygit:toggle()
			end
		end

		function _HORIZONTAL_TOGGLE()
			vim.cmd("ToggleTerm direction=horizontal")
		end

		local node = Terminal:new({
			cmd = "node",
			hidden = true
		})

		function _NODE_TOGGLE()
			node:toggle()
		end

		local ncdu = Terminal:new({
			cmd = "ncdu",
			hidden = true
		})

		function _NCDU_TOGGLE()
			ncdu:toggle()
		end

		local htop = Terminal:new({
			cmd = "htop",
			hidden = true
		})

		function _HTOP_TOGGLE()
			htop:toggle()
		end

		local python = Terminal:new({
			cmd = "python",
			hidden = true
		})

		function _PYTHON_TOGGLE()
			python:toggle()
		end

		function run_file()
			local filetype = vim.bo.filetype
			local filename = vim.fn.expand('%:p')
			
			local commands = {
				python = 'python3 "' .. filename .. '"',
				c = 'gcc "' .. filename .. '" -o /tmp/a.out && /tmp/a.out',
				cpp = 'g++ "' .. filename .. '" -o /tmp/a.out && /tmp/a.out',
				rust = 'cargo run',
				javascript = 'node "' .. filename .. '"',
				typescript = 'ts-node "' .. filename .. '"',
				sh = 'bash "' .. filename .. '"',
				lua = 'lua "' .. filename .. '"',
				go = 'go run "' .. filename .. '"',
			}
			
			local cmd = commands[filetype]
			if not cmd then
				vim.notify('No run command configured for: ' .. filetype, vim.log.levels.WARN)
				return
			end
			
			local Terminal = require("toggleterm.terminal").Terminal
			local run_term = Terminal:new({
				cmd = cmd,
				direction = "float",
				close_on_exit = false,
				on_open = function(term)
					vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
					vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-q>", [[<C-\><C-n>:close<CR>]], {noremap = true, silent = true})
					vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-c><C-c>", [[<C-\><C-n>:close<CR>]], {noremap = true, silent = true})
				end,
			})
			run_term:toggle()
		end

		_G.RUN_FILE = run_file


		function _G.DEBUG_FILE()
			local filetype = vim.bo.filetype
			local filename = vim.fn.expand('%:p')
			
			if filetype == "javascript" then
				vim.fn.system("lsof -ti:9229 | xargs kill -9 2>/dev/null")
				local Terminal = require("toggleterm.terminal").Terminal
				local debug_term = Terminal:new({
					cmd = "node inspect " .. vim.fn.shellescape(filename),
					direction = "float",
					close_on_exit = false,
					on_open = function(term)
						vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
						vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-q>", [[<C-\><C-n>:close<CR>]], {noremap = true, silent = true})
						vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-c><C-c>", [[<C-\><C-n>:close<CR>]], {noremap = true, silent = true})
						vim.defer_fn(function()
							if term and term.job_id then
								vim.api.nvim_chan_send(term.job_id, "cont\n")
							end
						end, 500)
					end,
				})
				debug_term:toggle()
				
			elseif filetype == "python" then
				local Terminal = require("toggleterm.terminal").Terminal
				local debug_term = Terminal:new({
					cmd = 'python3 -m pdb "' .. filename .. '"',
					direction = "float",
					close_on_exit = false,
					on_open = function(term)
						vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
						vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-q>", [[<C-\><C-n>:close<CR>]], {noremap = true, silent = true})
						vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-c><C-c>", [[<C-\><C-n>:close<CR>]], {noremap = true, silent = true})
						vim.defer_fn(function()
							if term and term.job_id then
								vim.api.nvim_chan_send(term.job_id, "c\n")
							end
						end, 500)
					end,
				})
				debug_term:toggle()
				
			elseif filetype == "typescript" then
				vim.fn.system("lsof -ti:9229 | xargs kill -9 2>/dev/null")
				local Terminal = require("toggleterm.terminal").Terminal
				local debug_term = Terminal:new({
					cmd = 'node --inspect --require ts-node/register "' .. filename .. '"',
					direction = "float",
					close_on_exit = false,
					on_open = function(term)
						vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
						vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-q>", [[<C-\><C-n>:close<CR>]], {noremap = true, silent = true})
						vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-c><C-c>", [[<C-\><C-n>:close<CR>]], {noremap = true, silent = true})
					end,
				})
				debug_term:toggle()
				
			else
				vim.notify('No debug command configured for: ' .. filetype, vim.log.levels.WARN)
			end
		end	

	end
}