-- Claude Code integration: https://github.com/coder/claudecode.nvim
-- Runs an MCP/WebSocket server that the `claude` CLI connects to, giving
-- diff accept/reject UI, @file and visual-selection context sending, etc.
local function gh(repo) return 'https://github.com/' .. repo end

-- snacks.nvim provides the floating terminal UI claudecode.nvim uses.
vim.pack.add {
  gh 'folke/snacks.nvim',
  gh 'coder/claudecode.nvim',
}

require('snacks').setup {}
require('claudecode').setup {}

vim.keymap.set('n', '<leader>ac', '<cmd>ClaudeCode<CR>', { desc = '[A]I [C]laude toggle' })
vim.keymap.set('v', '<leader>as', '<cmd>ClaudeCodeSend<CR>', { desc = '[A]I [S]end selection' })
vim.keymap.set('n', '<leader>as', '<cmd>ClaudeCodeTreeAdd<CR>', { desc = '[A]I [S]end file (from tree)' })
vim.keymap.set('n', '<leader>aa', '<cmd>ClaudeCodeDiffAccept<CR>', { desc = '[A]I [A]ccept diff' })
vim.keymap.set('n', '<leader>ad', '<cmd>ClaudeCodeDiffDeny<CR>', { desc = '[A]I [D]eny diff' })

-- Only picks the model a *new* session launches with (passes `--model` at
-- process spawn). To switch models mid-session without losing context, type
-- `/model` directly into the running Claude terminal instead.
vim.keymap.set('n', '<leader>am', '<cmd>ClaudeCodeSelectModel<CR>', { desc = '[A]I select [M]odel (new session)' })
