local M = {}

---@class Buffer
---@field id number Buffer number
---@field name string Buffer name
---@field path string Full path of the buffer
---@field modified boolean Whether the buffer has been modified
---@field filetype string Filetype of the buffer

-- Get all buffers
---@return Buffer[] buffers List of buffers
function M.list_buffers()
  local buffers = {}
  for bufnr = 1, vim.fn.bufnr('$') do
    if vim.fn.bufexists(bufnr) == 1 and vim.fn.buflisted(bufnr) == 1 then
      local buffer = {
        id = bufnr,
        name = vim.fn.bufname(bufnr),
        path = vim.fn.fnamemodify(vim.fn.bufname(bufnr), ':p'),
        modified = vim.fn.getbufvar(bufnr, '&modified') == 1,
        filetype = vim.fn.getbufvar(bufnr, '&filetype'),
      }
      table.insert(buffers, buffer)
    end
  end
  return buffers
end

-- Open buffer by ID
---@param bufnr number Buffer number to open
function M.open_buffer(bufnr)
  if vim.fn.bufexists(bufnr) == 1 then
    vim.api.nvim_set_current_buf(bufnr)
    return true
  end
  return false
end

-- Delete buffer by ID
---@param bufnr number Buffer number to delete
function M.delete_buffer(bufnr)
  -- バッファが存在しリストに含まれているか確認
  if vim.fn.bufexists(bufnr) == 1 and vim.fn.buflisted(bufnr) == 1 then
    -- 現在のバッファを保存
    local current_buf = vim.api.nvim_get_current_buf()

    -- 削除対象が現在のバッファの場合、別のバッファに切り替え
    if current_buf == bufnr then
      local other_bufs = vim.tbl_filter(function(b)
        return vim.fn.bufexists(b) == 1 and vim.fn.buflisted(b) == 1 and b ~= bufnr
      end, vim.api.nvim_list_bufs())

      if #other_bufs > 0 then
        vim.api.nvim_set_current_buf(other_bufs[1])
      end
    end

    -- バッファを削除
    local success = pcall(function()
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)

    -- 削除の確認
    return success and (vim.fn.buflisted(bufnr) == 0)
  end
  return false
end

-- Delete multiple buffers
---@param bufnrs number[] List of buffer numbers to delete
function M.bulk_delete(bufnrs)
  local results = {}

  -- 削除対象のバッファを収集
  local valid_bufnrs = vim.tbl_filter(function(bufnr)
    return vim.fn.bufexists(bufnr) == 1 and vim.fn.buflisted(bufnr) == 1
  end, bufnrs)

  -- 現在のバッファが削除対象に含まれている場合、別のバッファに切り替え
  local current_buf = vim.api.nvim_get_current_buf()
  if vim.tbl_contains(valid_bufnrs, current_buf) then
    local other_bufs = vim.tbl_filter(function(b)
      return vim.fn.bufexists(b) == 1
        and vim.fn.buflisted(b) == 1
        and not vim.tbl_contains(valid_bufnrs, b)
    end, vim.api.nvim_list_bufs())

    if #other_bufs > 0 then
      vim.api.nvim_set_current_buf(other_bufs[1])
    end
  end

  -- バッファを削除
  for _, bufnr in ipairs(bufnrs) do
    results[bufnr] = M.delete_buffer(bufnr)
  end

  return results
end

return M
