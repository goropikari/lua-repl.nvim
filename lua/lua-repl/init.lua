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

local function prevent_edit_in_protected_area()
  local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
  local n = state:get_last_line_number()
  if row < n then
    if state:get_notified() then
      return
    end
    state:set_notified(true)
    vim.notify('Editing above line ' .. n .. ' is not allowed!', vim.log.levels.ERROR)
  end
end

local function setup_buffer()
  state:set_prompt_bufnr(vim.api.nvim_create_buf(false, true))
  vim.api.nvim_set_option_value('filetype', 'lua', { buf = state:get_prompt_bufnr() })
  vim.api.nvim_set_option_value('syntax', 'lua', { buf = state:get_prompt_bufnr() })

  vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'InsertEnter', 'CursorMovedI' }, {
    buffer = state:get_prompt_bufnr(),
    callback = prevent_edit_in_protected_area,
  })
end

local function setup_keymap()
  local bufnr = state:get_prompt_bufnr()

  vim.keymap.set({ 'i', 'n' }, '<c-s>', function()
    local lines
    local n = state:get_last_line_number()
    if n == 0 then
      lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    else
      lines = vim.api.nvim_buf_get_lines(bufnr, n - 1, -1, false)
    end

    local result = vim.split(run_lua_code_with_output(vim.fn.join(lines, '\n')), '\n')
    vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, vim.iter({ '', '---Result---', result, '------------', '' }):flatten():totable())
    win.move_bottom(bufnr)
    state:set_last_line_number(vim.api.nvim_buf_line_count(bufnr))
    state:set_notified(false)
  end, {
    buffer = bufnr,
  })

  vim.keymap.set({ 'n' }, '<c-c>', function()
    win.close(bufnr)
  end, {
    buffer = bufnr,
  })

  vim.keymap.set({ 'n' }, '<c-l>', function()
    local bufnr = state:get_prompt_bufnr()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
    state:set_last_line_number(0)
    state:set_notified(false)
  end, {
    buffer = bufnr,
  })
end

function M.setup(opts)
  -- global_config = vim.tbl_deep_extend('force', default_config, opts or {})
  setup_buffer()
  setup_keymap()
end

function M.open()
  win.open(state:get_prompt_bufnr())
end

function M.close()
  win.close(state:get_prompt_bufnr())
end

function M.toggle()
  win.toggle(state:get_prompt_bufnr())
end

vim.api.nvim_create_user_command('LuaREPL', M.toggle, {})

return M
