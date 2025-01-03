local M = {}

---@class State
---@field prompt_bufnr integer
---@field last_line_number integer
---@field notified boolean
---
---@field get_prompt_bufnr fun(State):integer
---@field get_last_line_number fun(State):integer
---@field set_prompt_bufnr fun(State, integer)
---@field set_last_line_number fun(State, integer)
---@field get_notified fun(State):boolean
---@field set_notified fun(State, boolean)

---@return State
function M.new()
  ---@type State
  ---@diagnostic disable-next-line
  local obj = {
    prompt_bufnr = -1,
    last_line_number = 0,
  }

  ---@param self State
  obj.get_prompt_bufnr = function(self)
    return self.prompt_bufnr
  end

  ---@param self State
  ---@param bufnr integer
  obj.set_prompt_bufnr = function(self, bufnr)
    self.prompt_bufnr = bufnr
  end

  ---@param self State
  obj.get_last_line_number = function(self)
    return self.last_line_number
  end

  ---@param self State
  ---@param line_number integer 0-index
  obj.set_last_line_number = function(self, line_number)
    self.last_line_number = line_number
  end

  ---@param self State
  ---@return boolean
  obj.get_notified = function(self)
    return self.notified
  end

  ---@param self State
  obj.set_notified = function(self, notified)
    self.notified = notified
  end

  return obj
end

return M
