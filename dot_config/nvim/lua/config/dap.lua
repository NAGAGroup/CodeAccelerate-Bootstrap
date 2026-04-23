-- ============================================================================
-- DAP Configuration Module for Neovim v0.12
-- ============================================================================
-- Debug Adapter Protocol setup with nvim-dap, nvim-dap-ui, codelldb, and debugpy.
-- No dap.setup({}) call needed — nvim-dap auto-initializes.
-- ============================================================================

-- ============================================================================
-- Section 1: Module Setup and Locals
-- ============================================================================

local dap   = require('dap')
local dapui = require('dapui')

-- ============================================================================
-- Section 2: Highlight Groups
-- ============================================================================
-- Set all 5 highlight groups BEFORE sign_define so signs can reference them.

vim.api.nvim_set_hl(0, 'DapBreakpoint',          { fg = '#e06c75' })  -- red
vim.api.nvim_set_hl(0, 'DapBreakpointCondition',  { fg = '#e5c07b' })  -- yellow
vim.api.nvim_set_hl(0, 'DapBreakpointRejected',   { fg = '#5c6370' })  -- gray
vim.api.nvim_set_hl(0, 'DapLogPoint',             { fg = '#61afef' })  -- blue
vim.api.nvim_set_hl(0, 'DapStopped',              { fg = '#98c379' })  -- green

-- ============================================================================
-- Section 3: Gutter Signs (Nerd Font Codicons)
-- ============================================================================

vim.fn.sign_define('DapBreakpoint',          { text = '',  texthl = 'DapBreakpoint',         linehl = '', numhl = '' })
vim.fn.sign_define('DapBreakpointCondition', { text = '',  texthl = 'DapBreakpointCondition', linehl = '', numhl = '' })
vim.fn.sign_define('DapBreakpointRejected',  { text = '',  texthl = 'DapBreakpointRejected',  linehl = '', numhl = '' })
vim.fn.sign_define('DapLogPoint',            { text = '',  texthl = 'DapLogPoint',            linehl = '', numhl = '' })
vim.fn.sign_define('DapStopped',             { text = '',  texthl = 'DapStopped',             linehl = '', numhl = '' })

-- ============================================================================
-- Section 4: codelldb Adapter (C/C++)
-- ============================================================================

dap.adapters.codelldb = {
  type = 'server',
  port = '${port}',
  executable = {
    command = vim.fn.stdpath('data') .. '/mason/bin/codelldb',
    args    = { '--port', '${port}' },
  },
}

-- C/C++ launch configurations
dap.configurations.cpp = {
  {
    name    = 'Launch file',
    type    = 'codelldb',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd            = '${workspaceFolder}',
    stopOnEntry    = false,
    terminal       = 'integrated',
  },
  {
    name        = 'Attach to process',
    type        = 'codelldb',
    request     = 'attach',
    processId   = require('dap.utils').pick_process,
    cwd         = '${workspaceFolder}',
  },
}
-- C shares the same configurations as C++
dap.configurations.c = dap.configurations.cpp

-- ============================================================================
-- Section 5: debugpy Adapter (Python)
-- ============================================================================

dap.adapters.debugpy = {
  type    = 'executable',
  command = vim.fn.stdpath('data') .. '/mason/bin/debugpy-adapter',
}

-- Helper: detect .venv python or fall back to system python
local function get_python_path()
  local venv = vim.fn.getcwd() .. '/.venv/bin/python'
  if vim.fn.executable(venv) == 1 then
    return venv
  end
  return vim.fn.exepath('python3') ~= '' and vim.fn.exepath('python3') or 'python'
end

dap.configurations.python = {
  {
    name       = 'Launch file',
    type       = 'debugpy',
    request    = 'launch',
    program    = '${file}',
    pythonPath = get_python_path,
  },
  {
    name       = 'Launch with args',
    type       = 'debugpy',
    request    = 'launch',
    program    = function()
      return vim.fn.input('Path to file: ', vim.fn.getcwd() .. '/', 'file')
    end,
    args       = function()
      local args_str = vim.fn.input('Arguments: ')
      return vim.split(args_str, ' ', { trimempty = true })
    end,
    pythonPath = get_python_path,
  },
}

-- ============================================================================
-- Section 6: nvim-dap-ui Setup
-- ============================================================================

dapui.setup({
  layouts = {
    {
      -- Left panel: scopes, breakpoints, stacks, watches (40% width)
      elements = {
        { id = 'scopes',      size = 0.25 },
        { id = 'breakpoints', size = 0.25 },
        { id = 'stacks',      size = 0.25 },
        { id = 'watches',     size = 0.25 },
      },
      size     = 40,
      position = 'left',
    },
    {
      -- Bottom panel: REPL and console (10% height)
      elements = {
        { id = 'repl',    size = 0.5 },
        { id = 'console', size = 0.5 },
      },
      size     = 10,
      position = 'bottom',
    },
  },
  controls = {
    enabled = true,
    element = 'repl',
  },
  floating = {
    border = 'rounded',
  },
})

-- ============================================================================
-- Section 7: Auto-Open/Close Listeners
-- ============================================================================
-- Auto-open dapui when a debug session starts

dap.listeners.before.attach.dapui_config  = function() dapui.open() end
dap.listeners.before.launch.dapui_config  = function() dapui.open() end

-- Auto-close dapui when a debug session ends
dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
dap.listeners.before.event_exited.dapui_config     = function() dapui.close() end

-- ============================================================================
-- Section 8: All 21 DAP Keymaps
-- ============================================================================

-- Breakpoints
vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint,
  { desc = 'DAP: toggle breakpoint' })
vim.keymap.set('n', '<leader>dB', function()
  dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, { desc = 'DAP: conditional breakpoint' })

-- Execution control
vim.keymap.set('n', '<leader>dc', dap.continue,    { desc = 'DAP: continue' })
vim.keymap.set('n', '<leader>dn', dap.step_over,   { desc = 'DAP: step over' })
vim.keymap.set('n', '<leader>di', dap.step_into,   { desc = 'DAP: step into' })
vim.keymap.set('n', '<leader>do', dap.step_out,    { desc = 'DAP: step out' })
vim.keymap.set('n', '<leader>dp', dap.pause,       { desc = 'DAP: pause' })
vim.keymap.set('n', '<leader>dt', dap.terminate,   { desc = 'DAP: terminate' })
vim.keymap.set('n', '<leader>dd', dap.disconnect,  { desc = 'DAP: disconnect' })
vim.keymap.set('n', '<leader>dC', dap.run_to_cursor, { desc = 'DAP: run to cursor' })

-- Run with args
vim.keymap.set('n', '<leader>da', function()
  dap.continue({ before = function(config)
    config.args = vim.split(vim.fn.input('Args: '), ' ', { trimempty = true })
    return config
  end })
end, { desc = 'DAP: continue with args' })
vim.keymap.set('n', '<leader>dA', function()
  dap.run_last({ before = function(config)
    config.args = vim.split(vim.fn.input('Args: '), ' ', { trimempty = true })
    return config
  end })
end, { desc = 'DAP: run last with args' })

-- Session management
vim.keymap.set('n', '<leader>dL', dap.run_last,          { desc = 'DAP: run last' })
vim.keymap.set('n', '<leader>ds', dap.continue,          { desc = 'DAP: select config & continue' })

-- Stack navigation
vim.keymap.set('n', '<leader>dj', dap.down,              { desc = 'DAP: stack down' })
vim.keymap.set('n', '<leader>dk', dap.up,                { desc = 'DAP: stack up' })

-- UI controls
vim.keymap.set('n', '<leader>du', dapui.toggle,          { desc = 'DAP: toggle UI' })
vim.keymap.set('n', '<leader>dr', function()
  dapui.toggle({ reset = false })
  require('dap').repl.toggle()
end, { desc = 'DAP: toggle REPL' })

-- Evaluation
vim.keymap.set({ 'n', 'v' }, '<leader>de', function()
  dapui.eval(nil, { enter = true })
end, { desc = 'DAP: evaluate expression' })
vim.keymap.set('n', '<leader>dw', function()
  require('dap.ui.widgets').hover()
end, { desc = 'DAP: hover eval' })
