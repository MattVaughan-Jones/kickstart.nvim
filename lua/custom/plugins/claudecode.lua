-- Claude Code integration: https://github.com/coder/claudecode.nvim
-- Runs an MCP/WebSocket server that the `claude` CLI connects to, giving
-- diff accept/reject UI, @file and visual-selection context sending, etc.
-- Claude itself runs in a separate tmux pane, never inside nvim.
local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'coder/claudecode.nvim' }

require('claudecode').setup {
  -- Single-buffer inline diff (deleted/added lines interleaved) instead of side-by-side.
  diff_opts = { layout = 'unified' },
  -- "none" keeps the WebSocket server (so the pane's `claude` can connect and
  -- receive selections) but makes every "open/show the terminal" call a no-op.
  terminal = { provider = 'none' },
}

-- Id (e.g. "%5") of the tmux pane running Claude, when we launched it.
local claude_pane

local function pane_alive(id)
  if not id then return false end
  vim.fn.system { 'tmux', 'display-message', '-p', '-t', id, '' }
  return vim.v.shell_error == 0
end

local function tmux_select(target)
  vim.fn.system { 'tmux', 'select-pane', unpack(target) }
end

-- Focus the existing Claude pane, or split a new one running `claude` in nvim's cwd.
local function claude_pane_open()
  if not vim.env.TMUX then
    vim.notify('Not inside tmux', vim.log.levels.WARN)
    return
  end
  if pane_alive(claude_pane) then
    tmux_select { '-t', claude_pane }
    return
  end
  claude_pane = vim.trim(vim.fn.system { 'tmux', 'split-window', '-h', '-P', '-F', '#{pane_id}', '-c', vim.fn.getcwd(), 'claude' })
end

vim.keymap.set('n', '<leader>ac', claude_pane_open, { desc = '[A]I open/focus [C]laude tmux pane' })
vim.keymap.set('v', '<leader>as', '<cmd>ClaudeCodeSend<CR>', { desc = '[A]I [S]end selection' })
vim.keymap.set('n', '<leader>as', '<cmd>ClaudeCodeTreeAdd<CR>', { desc = '[A]I [S]end file (from tree)' })
vim.keymap.set('n', '<leader>af', function()
  local file = vim.api.nvim_buf_get_name(0)
  if file ~= '' then vim.cmd('ClaudeCodeAdd ' .. vim.fn.fnameescape(file)) end
end, { desc = '[A]I send current [F]ile' })
vim.keymap.set('n', '<leader>al', function()
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then return end
  local line = vim.api.nvim_win_get_cursor(0)[1]
  vim.cmd(('ClaudeCodeAdd %s %d %d'):format(vim.fn.fnameescape(file), line, line))
end, { desc = '[A]I send current [L]ine' })
vim.keymap.set('n', '<leader>aa', '<cmd>ClaudeCodeDiffAccept<CR>', { desc = '[A]I [A]ccept diff' })
vim.keymap.set('n', '<leader>ad', '<cmd>ClaudeCodeDiffDeny<CR>', { desc = '[A]I [D]eny diff' })

-- After a send, jump to the Claude pane (focus_after_send can't do this for
-- a session running outside nvim). Falls back to the pane on the right.
vim.api.nvim_create_autocmd('User', {
  pattern = 'ClaudeCodeSendComplete',
  callback = function()
    if not vim.env.TMUX then return end
    tmux_select(pane_alive(claude_pane) and { '-t', claude_pane } or { '-R' })
  end,
})
