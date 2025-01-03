local M = {}

---@param bufnr integer
---@return integer[]
local function get_windows_for_buffer(bufnr)
  local wins = vim.api.nvim_list_wins() -- すべてのウィンドウを取得
  local result = {}

  for _, win in ipairs(wins) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      table.insert(result, win) -- 対象バッファのウィンドウをリストに追加
    end
  end

  return result
end

M.get_windows_for_buffer = get_windows_for_buffer

---@param bufnr number
function M.move_bottom(bufnr)
  local last_num = vim.api.nvim_buf_line_count(bufnr)
  for _, winid in ipairs(get_windows_for_buffer(bufnr)) do
    vim.api.nvim_win_set_cursor(winid, { last_num, 0 })
  end
end

---@param prompt_bufnr integer
function M.open(prompt_bufnr)
  local editor_width = vim.o.columns
  local editor_height = vim.o.lines

  local win_width = math.floor(editor_width * 0.8)
  local win_height = math.floor(editor_height * 0.8)

  local win_col = math.floor((editor_width - win_width) / 2)
  local win_row = math.floor((editor_height - win_height) / 2)

  vim.api.nvim_open_win(prompt_bufnr, true, {
    title = ' write lua code (send <ctrl-s>, close <ctrl-c>, clear <ctrl-l>) ',
    title_pos = 'center',
    relative = 'editor',
    width = win_width,
    height = win_height,
    col = win_col,
    row = win_row,
    border = 'single',
  })
end

---@param prompt_bufnr integer
function M.close(prompt_bufnr)
  for _, winid in ipairs(get_windows_for_buffer(prompt_bufnr)) do
    vim.api.nvim_win_close(winid, true)
  end
end

---@param prompt_bufnr integer
function M.toggle(prompt_bufnr)
  local active = false
  active = active or (#get_windows_for_buffer(prompt_bufnr) > 0)
  if active then
    M.close(prompt_bufnr)
  else
    M.open(prompt_bufnr)
  end
end

return M
