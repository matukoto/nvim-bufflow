local api = vim.api
local buffer = require('bufflow.buffer')

local M = {}

---@class WindowConfig
---@field preview_enabled boolean
---@field preview_width number
---@field preview_position string

---@type number|nil
local list_win = nil
---@type number|nil
local list_buf = nil
---@type number|nil
local preview_win = nil
---@type table<number, Buffer>
local buffer_cache = {}

local function create_list_buffer()
  local bufnr = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(bufnr, 'bufhidden', 'wipe')
  api.nvim_buf_set_option(bufnr, 'filetype', 'bufflow')
  api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')
  return bufnr
end

local function get_window_config(config)
  local width = math.floor(vim.o.columns * config.preview_width)
  local height = vim.o.lines - 4

  local list_width = vim.o.columns - (config.preview_enabled and width or 0)

  return {
    list = {
      width = list_width,
      height = height,
      row = 1,
      col = 0,
      relative = 'editor',
      style = 'minimal',
      border = 'rounded',
    },
    preview = config.preview_enabled and {
      width = width,
      height = height,
      row = 1,
      col = list_width,
      relative = 'editor',
      style = 'minimal',
      border = 'rounded',
    } or nil,
  }
end

local function update_buffer_list()
  if not list_buf or not api.nvim_buf_is_valid(list_buf) then
    return
  end

  local buffers = buffer.list_buffers()
  buffer_cache = {}

  local lines = {}
  for _, buf in ipairs(buffers) do
    buffer_cache[#lines + 1] = buf
    local modified = buf.modified and ' [+]' or ''
    table.insert(lines, string.format('%s%s', buf.name, modified))
  end

  api.nvim_buf_set_lines(list_buf, 0, -1, false, lines)
end

local function setup_buffer_autocmds()
  local group = api.nvim_create_augroup('BufFlow', { clear = true })

  api.nvim_create_autocmd('BufWritePost', {
    group = group,
    callback = function()
      update_buffer_list()
    end,
  })
end

---Create buffer list window
---@param config WindowConfig
function M.create_window(config)
  if list_win and api.nvim_win_is_valid(list_win) then
    return
  end

  list_buf = create_list_buffer()
  local win_config = get_window_config(config)

  list_win = api.nvim_open_win(list_buf, true, win_config.list)

  if config.preview_enabled and win_config.preview then
    preview_win = api.nvim_open_win(0, false, win_config.preview)
  end

  update_buffer_list()
  setup_buffer_autocmds()
end

---Close windows
function M.close_windows()
  if preview_win and api.nvim_win_is_valid(preview_win) then
    api.nvim_win_close(preview_win, true)
    preview_win = nil
  end

  if list_win and api.nvim_win_is_valid(list_win) then
    api.nvim_win_close(list_win, true)
    list_win = nil
  end

  if list_buf and api.nvim_buf_is_valid(list_buf) then
    api.nvim_buf_delete(list_buf, { force = true })
    list_buf = nil
  end
end

---Handle buffer preview
---@param linenr number
function M.handle_preview(linenr)
  if not preview_win or not api.nvim_win_is_valid(preview_win) then
    return
  end

  local buf_info = buffer_cache[linenr]
  if not buf_info then
    return
  end

  if api.nvim_buf_is_valid(buf_info.bufnr) then
    api.nvim_win_set_buf(preview_win, buf_info.bufnr)
  end
end

---Get selected buffer
---@return Buffer|nil
function M.get_selected_buffer()
  if not list_win or not api.nvim_win_is_valid(list_win) then
    return nil
  end

  local linenr = api.nvim_win_get_cursor(list_win)[1]
  return buffer_cache[linenr]
end

return M
