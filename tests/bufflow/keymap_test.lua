local eq = assert.are.same
local T = require('mini.test')

local keymap = require('bufflow.keymap')
local ui = require('bufflow.ui')

local test_file1 = 'test_buffer1.txt'
local test_file2 = 'test_buffer2.txt'

local config = {
  close = 'q',
  delete = 'd',
  bulk_delete = 'D',
  preview = 'p',
  open = '<CR>'
}

local window_config = {
  preview_enabled = true,
  preview_width = 0.5,
  preview_position = 'right'
}

local new_set = MiniTest.new_set {
  hooks = {
    pre_case = function()
      -- Create test buffers
      vim.cmd('new ' .. test_file1)
      vim.cmd('new ' .. test_file2)
      ui.create_window(window_config)
      keymap.setup(config)
    end,
    post_case = function()
      -- Clean up
      ui.close_windows()
      vim.cmd('bdelete! ' .. test_file1)
      vim.cmd('bdelete! ' .. test_file2)
    end,
  },
}

new_set {
  'keymap_setup': function()
    local bufnr = vim.fn.bufnr('bufflow')
    eq(bufnr > 0, true, 'Buffer should exist')

    -- Get all keymaps for the buffer
    local keymaps = vim.api.nvim_buf_get_keymap(bufnr, 'n')
    local has_mappings = {
      close = false,
      delete = false,
      bulk_delete = false,
      preview = false,
      open = false,
    }

    for _, map in ipairs(keymaps) do
      if map.lhs == config.close then has_mappings.close = true end
      if map.lhs == config.delete then has_mappings.delete = true end
      if map.lhs == config.bulk_delete then has_mappings.bulk_delete = true end
      if map.lhs == config.preview then has_mappings.preview = true end
      if map.lhs == config.open then has_mappings.open = true end
    end

    eq(has_mappings.close, true, 'Should have close mapping')
    eq(has_mappings.delete, true, 'Should have delete mapping')
    eq(has_mappings.bulk_delete, true, 'Should have bulk delete mapping')
    eq(has_mappings.preview, true, 'Should have preview mapping')
    eq(has_mappings.open, true, 'Should have open mapping')
  end,

  'buffer_operations': function()
    local bufnr = vim.fn.bufnr('bufflow')
    local initial_bufs = #vim.api.nvim_list_bufs()

    -- Test delete operation
    vim.api.nvim_win_set_cursor(0, {1, 0})
    vim.api.nvim_feedkeys(config.delete, 'nx', true)
    vim.cmd('sleep 100m') -- Wait for operation to complete
    
    local after_delete = #vim.api.nvim_list_bufs()
    eq(after_delete < initial_bufs, true, 'Should delete a buffer')

    -- Recreate window for remaining tests
    ui.create_window(window_config)
    keymap.setup(config)

    -- Test open operation
    vim.api.nvim_win_set_cursor(0, {1, 0})
    vim.api.nvim_feedkeys(config.open, 'nx', true)
    vim.cmd('sleep 100m')

    local windows = vim.api.nvim_list_wins()
    local found_preview = false
    for _, win in ipairs(windows) do
      if vim.api.nvim_win_get_buf(win) ~= bufnr then
        found_preview = true
        break
      end
    end
    eq(found_preview, true, 'Should open buffer in preview window')
  end,
}

return new_set
