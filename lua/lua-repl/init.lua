local M = {}

-- local default_config = {}
-- local global_config = {}
local state = require('lua-repl.state').new()
local win = require('lua-repl.window')

local function run_lua_code_with_output(code)
  -- 出力を格納するテーブル
  ---@type string[]
  local output = {}

  -- 元の print 関数を退避
  local original_print = print
  local original_vim_print = vim.print

  -- カスタム print 関数を設定
  print = function(...)
    local args = { ... }
    for i, v in ipairs(args) do
      args[i] = vim.inspect(v)
    end
    table.insert(output, table.concat(args, '\n'))
  end

  vim.print = function(...)
    local args = { ... }
    for i, v in ipairs(args) do
      args[i] = vim.inspect(v) -- 全て文字列に変換
    end
    table.insert(output, table.concat(args, '\n'))
  end

  local success, result_or_error = pcall(loadstring(code))

  print = original_print
  vim.print = original_vim_print

  if not success then
    return 'Error: ' .. result_or_error
  end

  -- print の出力を結合
  local print_output = table.concat(output, '\n')
  return print_output ~= '' and print_output or ''
end

local function setup_buffer()
  state.prompt_bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value('filetype', 'lua', { buf = state:get_prompt_bufnr() })
  vim.api.nvim_set_option_value('syntax', 'lua', { buf = state:get_prompt_bufnr() })

  state.viewer_bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value('filetype', 'lua', { buf = state:get_viewer_bufnr() })
  vim.api.nvim_set_option_value('syntax', 'lua', { buf = state:get_viewer_bufnr() })
end

local function setup_keymap()
  vim.keymap.set({ 'i', 'n' }, '<c-s>', function()
    local lines = vim.api.nvim_buf_get_lines(state:get_prompt_bufnr(), 0, -1, false)
    vim.api.nvim_buf_set_lines(state:get_prompt_bufnr(), 0, -1, false, {})

    local result = vim.split(run_lua_code_with_output(vim.fn.join(lines, '\n')), '\n')
    vim.api.nvim_buf_set_lines(state:get_viewer_bufnr(), -1, -1, false, lines)
    vim.api.nvim_buf_set_lines(state:get_viewer_bufnr(), -1, -1, false, vim.iter({ '', '---Result---', result, '------------', '', '' }):flatten():totable())
    win.move_bottom(state:get_viewer_bufnr())
  end, {
    buffer = state:get_prompt_bufnr(),
  })

  vim.keymap.set({ 'n' }, 'q', function()
    win.close(state:get_prompt_bufnr(), state:get_viewer_bufnr())
  end, {
    buffer = state:get_prompt_bufnr(),
  })
  vim.keymap.set({ 'n' }, 'q', function()
    win.close(state:get_prompt_bufnr(), state:get_viewer_bufnr())
  end, {
    buffer = state:get_viewer_bufnr(),
  })
end

function M.setup(opts)
  -- global_config = vim.tbl_deep_extend('force', default_config, opts or {})
  setup_buffer()
  setup_keymap()
end

function M.open()
  win.open(state:get_prompt_bufnr(), state:get_viewer_bufnr())
end

function M.close()
  win.close(state:get_prompt_bufnr(), state:get_viewer_bufnr())
end

function M.toggle()
  win.toggle(state:get_prompt_bufnr(), state:get_viewer_bufnr())
end

vim.api.nvim_create_user_command('LuaREPL', M.toggle, {})

return M
