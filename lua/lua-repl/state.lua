local M = {}

---@class State
---@field prompt_bufnr integer
---@field viewer_bufnr integer
---@field get_prompt_bufnr fun(State):integer
---@field get_viewer_bufnr fun(State):integer

---@return State
function M.new()
  ---@type State
  ---@diagnostic disable-next-line
  local obj = {
    prompt_bufnr = -1,
    viewer_bufnr = -1,
  }

  obj.get_prompt_bufnr = function(self)
    return self.prompt_bufnr
  end
  obj.get_viewer_bufnr = function(self)
    return self.viewer_bufnr
  end

  return obj
end

return M
