-- vim-tmux-navigator: unified <C-hjkl> pane/split navigation across both
-- neovim splits and tmux panes, with no prefix key. When you're at the edge
-- of the neovim window grid, the same keys hand off to tmux (see the
-- matching bindings in ~/.tmux.conf).
--
-- Normal mode only: from terminal mode (e.g. the claudecode.nvim terminal),
-- exit with <Esc><Esc> first, then navigate as usual.
local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'christoomey/vim-tmux-navigator' }

-- Define our own mappings instead of the plugin's defaults, so this stays
-- consistent with the rest of this config.
vim.g.tmux_navigator_no_mappings = 1

local function navigate(direction) return '<cmd>TmuxNavigate' .. direction .. '<CR>' end

vim.keymap.set('n', '<C-h>', navigate 'Left', { desc = 'Move focus to the left window/pane' })
vim.keymap.set('n', '<C-l>', navigate 'Right', { desc = 'Move focus to the right window/pane' })
vim.keymap.set('n', '<C-j>', navigate 'Down', { desc = 'Move focus to the lower window/pane' })
vim.keymap.set('n', '<C-k>', navigate 'Up', { desc = 'Move focus to the upper window/pane' })
