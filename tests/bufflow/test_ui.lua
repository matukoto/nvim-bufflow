local T = require('mini.test')
local ui = require('bufflow.ui')

local new_set = T.new_set

local test_files = {
  'test_ui1.txt',
  'test_ui2.txt',
}

local window_config = {
  preview_enabled = true,
  preview_width = 0.5,
  preview_position = 'right',
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

-- Tests for UI operations
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

T['ui operations'] = new_set()

T['ui operations']['create_window'] = function()
  -- Create windows
  ui.create_window(window_config)
  vim.cmd('sleep 100m')

  -- Check main list window
  local list_win = vim.fn.bufwinid('bufflow')
  assert(list_win > 0, 'Buffer list window should exist')

  -- Check preview window if enabled
  if window_config.preview_enabled then
    local windows = vim.api.nvim_list_wins()
    local preview_found = false

    for _, win in ipairs(windows) do
      local win_config = vim.api.nvim_win_get_config(win)
      if win_config.relative ~= '' then
        preview_found = true
        break
      end
    end

    assert(preview_found, 'Preview window should exist')
  end
end

T['ui operations']['handle_preview'] = function()
  -- Create windows
  ui.create_window(window_config)
  vim.cmd('sleep 100m')

  -- Get initial window count
  local initial_wins = #vim.api.nvim_list_wins()

  -- Toggle preview
  ui.toggle_preview()
  vim.cmd('sleep 100m')

  -- Check window count changed
  local toggle_wins = #vim.api.nvim_list_wins()
  assert(toggle_wins ~= initial_wins, 'Window count should change after toggle')

  -- Toggle back
  ui.toggle_preview()
  vim.cmd('sleep 100m')

  -- Check windows restored
  local final_wins = #vim.api.nvim_list_wins()
  assert(final_wins == initial_wins, 'Window count should be restored')
end

T['ui operations']['window_layout'] = function()
  -- Create windows
  ui.create_window(window_config)
  vim.cmd('sleep 100m')

  -- Check list window position
  local list_win = vim.fn.bufwinid('bufflow')
  local list_config = vim.api.nvim_win_get_config(list_win)

  -- List window should be a normal window
  assert(list_config.relative == '', 'List window should be a normal window')

  -- Check preview window if enabled
  if window_config.preview_enabled then
    local windows = vim.api.nvim_list_wins()
    local preview_found = false

    for _, win in ipairs(windows) do
      local win_config = vim.api.nvim_win_get_config(win)
      if win_config.relative ~= '' then
        preview_found = true
        -- Check preview window position
        if window_config.preview_position == 'right' then
          assert(win_config.anchor == 'NW', 'Preview window should anchor to top-left')
        end
        break
      end
    end

    assert(preview_found, 'Preview window should exist with correct layout')
  end
end

return T
