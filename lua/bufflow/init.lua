local M = {}

local buffer = require('bufflow.buffer')
local ui = require('bufflow.ui')
local keymap = require('bufflow.keymap')

---@class Config
---@field preview table
---@field keymaps table
local default_config = {
  preview = {
    enabled = true,
    width = 0.5,
    position = 'right'
  },
  keymaps = {
    close = 'q',
    delete = 'd',
    bulk_delete = 'D',
    preview = 'p',
    open = '<CR>'
  }
}

local config = vim.deepcopy(default_config)

---@param user_config? Config
function M.setup(user_config)
  config = vim.tbl_deep_extend('force', default_config, user_config or {})
end

---Open buffer list window
function M.open()
  ui.create_window({
    preview_enabled = config.preview.enabled,
    preview_width = config.preview.width,
    preview_position = config.preview.position
  })
  
  -- Setup keymaps after window creation
  vim.schedule(function()
    keymap.setup(config.keymaps)
  end)
end

---Close buffer list window
function M.close()
  ui.close_windows()
end

---Delete current buffer
function M.delete_current()
  local current = vim.api.nvim_get_current_buf()
  if buffer.delete_buffer(current) then
    -- If in buffer list window, close it
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.api.nvim_buf_get_option(bufnr, 'filetype') == 'bufflow' then
      M.close()
    end
  end
end

-- Setup commands
local function create_commands()
  vim.api.nvim_create_user_command('BufFlow', M.open, {})
  vim.api.nvim_create_user_command('BufFlowClose', M.close, {})
  vim.api.nvim_create_user_command('BufFlowDelete', M.delete_current, {})
end

-- Initialize plugin
create_commands()

return M
