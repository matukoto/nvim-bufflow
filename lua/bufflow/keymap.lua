local api = vim.api
local buffer = require('bufflow.buffer')
local ui = require('bufflow.ui')

local M = {}

---@class KeyConfig
---@field close string
---@field delete string
---@field bulk_delete string
---@field preview string
---@field open string

local selected_buffers = {}

---Handle buffer deletion
local function delete_selected_buffer()
  local buf = ui.get_selected_buffer()
  if not buf then
    return
  end

  if buffer.delete_buffer(buf.bufnr) then
    ui.close_windows()
  end
end

---Handle bulk buffer deletion
local function bulk_delete_buffers()
  if #selected_buffers == 0 then
    return
  end

  buffer.bulk_delete(selected_buffers)
  selected_buffers = {}
  ui.close_windows()
end

---Toggle buffer selection for bulk operations
local function toggle_buffer_selection()
  local buf = ui.get_selected_buffer()
  if not buf then
    return
  end

  local idx = vim.tbl_contains(selected_buffers, buf.bufnr)
  if idx then
    table.remove(selected_buffers, idx)
  else
    table.insert(selected_buffers, buf.bufnr)
  end
end

---Handle buffer preview
local function preview_buffer()
  local win = api.nvim_get_current_win()
  local pos = api.nvim_win_get_cursor(win)
  ui.handle_preview(pos[1])
end

---Handle buffer open
local function open_buffer()
  local buf = ui.get_selected_buffer()
  if not buf then
    return
  end

  if buffer.open_buffer(buf.bufnr) then
    ui.close_windows()
  end
end

---Setup keymaps for buffer list window
---@param bufnr number
---@param config KeyConfig
local function setup_buffer_keymaps(bufnr, config)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  
  vim.keymap.set('n', config.close, ui.close_windows, opts)
  vim.keymap.set('n', config.delete, delete_selected_buffer, opts)
  vim.keymap.set('n', config.bulk_delete, bulk_delete_buffers, opts)
  vim.keymap.set('n', config.preview, preview_buffer, opts)
  vim.keymap.set('n', config.open, open_buffer, opts)
  vim.keymap.set('n', '<Space>', toggle_buffer_selection, opts)

  -- Auto preview on cursor move
  local group = api.nvim_create_augroup('BufFlowPreview', { clear = true })
  api.nvim_create_autocmd('CursorMoved', {
    group = group,
    buffer = bufnr,
    callback = preview_buffer,
  })
end

---Setup keymaps
---@param config KeyConfig
function M.setup(config)
  -- Wait for buffer list to be created
  vim.schedule(function()
    local bufnr = vim.fn.bufnr('bufflow')
    if bufnr > 0 then
      setup_buffer_keymaps(bufnr, config)
    end
  end)
end

return M
