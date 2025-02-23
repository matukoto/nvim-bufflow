local T = require('mini.test')
local keymap = require('bufflow.keymap')
local buffer = require('bufflow.buffer')
local ui = require('bufflow.ui')

local new_set = T.new_set

-- Test configuration
local config = {
  close = 'q',
  delete = 'd',
  bulk_delete = 'D',
  preview = 'p',
  open = '<CR>',
}

local window_config = {
  preview_enabled = true,
  preview_width = 0.5,
  preview_position = 'right',
}

local test_files = {
  'test_keymap1.txt',
  'test_keymap2.txt',
}

-- Setup test files and buffers
local function setup_test_environment()
  -- クリーンアップ
  vim.cmd('silent! %bwipeout!')
  for _, file in ipairs(test_files) do
    os.remove(file)
  end

  -- テストファイル作成
  for _, file in ipairs(test_files) do
    local f = io.open(file, 'w')
    if f then
      f:write('Test content for ' .. file)
      f:close()
    end
  end

  -- バッファ作成
  for _, file in ipairs(test_files) do
    vim.cmd('badd ' .. file)
  end

  -- 最初のバッファに移動
  vim.cmd('buffer ' .. vim.fn.bufnr(test_files[1]))

  -- UIとキーマップのセットアップ
  ui.create_window(window_config)
  vim.cmd('sleep 100m')
  keymap.setup(config)
end

-- Cleanup test environment
local function cleanup_test_environment()
  -- Close windows
  ui.close_windows()

  -- Delete buffers and files
  vim.cmd('silent! %bwipeout!')
  for _, file in ipairs(test_files) do
    os.remove(file)
  end
end

-- Tests for keymap operations
local T = new_set({
  hooks = {
    pre_case = function()
      cleanup_test_environment()
      setup_test_environment()
    end,
    post_case = function()
      cleanup_test_environment()
    end,
  },
})

T['keymap operations'] = new_set()

-- Test keymap setup
T['keymap operations']['keymap_setup'] = function()
  local bufnr = vim.fn.bufnr('bufflow')
  assert(bufnr > 0, 'Bufflow buffer should exist')

  local keymaps = vim.api.nvim_buf_get_keymap(bufnr, 'n')
  local has_mappings = {
    close = false,
    delete = false,
    bulk_delete = false,
    preview = false,
    open = false,
  }

  for _, map in ipairs(keymaps) do
    if map.lhs == config.close then
      has_mappings.close = true
    end
    if map.lhs == config.delete then
      has_mappings.delete = true
    end
    if map.lhs == config.bulk_delete then
      has_mappings.bulk_delete = true
    end
    if map.lhs == config.preview then
      has_mappings.preview = true
    end
    if map.lhs == config.open then
      has_mappings.open = true
    end
  end

  assert(has_mappings.close, 'Should have close mapping')
  assert(has_mappings.delete, 'Should have delete mapping')
  assert(has_mappings.bulk_delete, 'Should have bulk delete mapping')
  assert(has_mappings.preview, 'Should have preview mapping')
  assert(has_mappings.open, 'Should have open mapping')
end

-- Test buffer operations
T['keymap operations']['buffer_operations'] = function()
  -- Get bufflow window
  local bufnr = vim.fn.bufnr('bufflow')
  assert(bufnr > 0, 'Bufflow buffer should exist')

  local list_win = vim.fn.bufwinid('bufflow')
  assert(list_win > 0, 'Bufflow window should exist')

  -- Test delete operation
  local initial_bufs = #vim.api.nvim_list_bufs()
  vim.api.nvim_set_current_win(list_win)
  vim.api.nvim_win_set_cursor(list_win, { 1, 0 })
  vim.api.nvim_feedkeys(config.delete, 'nx', true)
  vim.cmd('sleep 100m')

  local after_delete = #vim.api.nvim_list_bufs()
  assert(after_delete < initial_bufs, 'Should delete a buffer')

  -- Test preview operation
  vim.api.nvim_set_current_win(list_win)
  vim.api.nvim_win_set_cursor(list_win, { 1, 0 })
  vim.api.nvim_feedkeys(config.preview, 'nx', true)
  vim.cmd('sleep 100m')

  local windows = vim.api.nvim_list_wins()
  local found_preview = false
  for _, win in ipairs(windows) do
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) ~= bufnr then
      found_preview = true
      break
    end
  end
  assert(found_preview, 'Should show buffer in preview window')
end

return T
