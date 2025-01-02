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

---@param bufnr number
function M.move_bottom(bufnr)
  local last_num = vim.api.nvim_buf_line_count(bufnr)
  for _, winid in ipairs(get_windows_for_buffer(bufnr)) do
    vim.api.nvim_win_set_cursor(winid, { last_num, 0 })
  end
end

---@param prompt_bufnr integer
---@param viewer_bufnr integer
function M.open(prompt_bufnr, viewer_bufnr)
  local editor_width = vim.o.columns
  local editor_height = vim.o.lines

  local win_width = math.floor(editor_width * 0.8 / 2) -- 2つ並べるために半分に分割
  local win_height = math.floor(editor_height * 0.8)

  local left_win_col = math.floor((editor_width - win_width * 2) / 2)
  local win_row = math.floor((editor_height - win_height) / 2)

  vim.api.nvim_open_win(prompt_bufnr, true, {
    title = ' write lua code (send <c-s>) ',
    title_pos = 'center',
    relative = 'editor',
    width = win_width,
    height = win_height,
    col = left_win_col - 1,
    row = win_row,
    border = 'single',
  })

  vim.api.nvim_open_win(viewer_bufnr, false, {
    title = 'result',
    title_pos = 'center',
    relative = 'editor',
    width = win_width,
    height = win_height,
    col = left_win_col + win_width + 1,
    row = win_row,
    style = 'minimal',
    border = 'single',
  })
end

---@param prompt_bufnr integer
---@param viewer_bufnr integer
function M.close(prompt_bufnr, viewer_bufnr)
  for _, winid in ipairs(get_windows_for_buffer(prompt_bufnr)) do
    vim.api.nvim_win_close(winid, true)
  end
  for _, winid in ipairs(get_windows_for_buffer(viewer_bufnr)) do
    vim.api.nvim_win_close(winid, true)
  end
end

---@param prompt_bufnr integer
---@param viewer_bufnr integer
function M.toggle(prompt_bufnr, viewer_bufnr)
  local active = false
  active = active or (#get_windows_for_buffer(prompt_bufnr) > 0)
  active = active or (#get_windows_for_buffer(viewer_bufnr) > 0)
  if active then
    M.close(prompt_bufnr, viewer_bufnr)
  else
    M.open(prompt_bufnr, viewer_bufnr)
  end
end

return M
