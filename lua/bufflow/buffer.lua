---@class Buffer
---@field bufnr number
---@field name string
---@field modified boolean
---@field listed boolean

local M = {}

---Get list of buffers
---@return Buffer[]
function M.list_buffers()
  local buffers = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      table.insert(buffers, M.get_buffer_info(bufnr))
    end
  end
  return buffers
end

---Get buffer information
---@param bufnr number
---@return Buffer
function M.get_buffer_info(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  return {
    bufnr = bufnr,
    name = name ~= '' and vim.fn.fnamemodify(name, ':~:.') or '[No Name]',
    modified = vim.api.nvim_buf_get_option(bufnr, 'modified'),
    listed = vim.api.nvim_buf_get_option(bufnr, 'buflisted')
  }
end

---Delete a buffer
---@param bufnr number
---@return boolean success
function M.delete_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  local success, err = pcall(vim.api.nvim_buf_delete, bufnr, { force = false })
  if not success then
    vim.notify('Failed to delete buffer: ' .. err, vim.log.levels.ERROR)
    return false
  end
  return true
end

---Bulk delete buffers
---@param bufnrs number[]
---@return boolean[] results List of deletion results
function M.bulk_delete(bufnrs)
  local results = {}
  for _, bufnr in ipairs(bufnrs) do
    table.insert(results, M.delete_buffer(bufnr))
  end
  return results
end

---Open a buffer
---@param bufnr number
---@return boolean success
function M.open_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  local success, err = pcall(vim.api.nvim_set_current_buf, bufnr)
  if not success then
    vim.notify('Failed to open buffer: ' .. err, vim.log.levels.ERROR)
    return false
  end
  return true
end

return M
