local eq = assert.are.same
local T = require('mini.test')

local ui = require('bufflow.ui')

local test_file = 'test_buffer.txt'
local config = {
  preview_enabled = true,
  preview_width = 0.5,
  preview_position = 'right'
}

local new_set = MiniTest.new_set {
  hooks = {
    pre_case = function()
      -- Create test buffer
      vim.cmd('new ' .. test_file)
    end,
    post_case = function()
      -- Clean up
      ui.close_windows()
      vim.cmd('bdelete! ' .. test_file)
    end,
  },
}

new_set {
  'create_window': function()
    ui.create_window(config)

    -- Check if windows are created
    local list_win = vim.fn.bufwinid('bufflow')
    eq(list_win > 0, true, 'List window should be created')
    
    -- Get all windows
    local windows = vim.api.nvim_list_wins()
    local preview_exists = false
    for _, win in ipairs(windows) do
      if win ~= list_win and vim.api.nvim_win_is_valid(win) then
        preview_exists = true
        break
      end
    end
    eq(preview_exists, true, 'Preview window should be created')
  end,

  'close_windows': function()
    ui.create_window(config)
    ui.close_windows()

    -- Get all windows
    local windows = vim.api.nvim_list_wins()
    local list_exists = false
    local preview_exists = false

    for _, win in ipairs(windows) do
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
      if ft == 'bufflow' then
        list_exists = true
      elseif win ~= vim.api.nvim_get_current_win() then
        preview_exists = true
      end
    end

    eq(list_exists, false, 'List window should be closed')
    eq(preview_exists, false, 'Preview window should be closed')
  end,

  'handle_preview': function()
    ui.create_window(config)
    local test_bufnr = vim.fn.bufnr(test_file)
    
    -- Simulate cursor movement to first line
    ui.handle_preview(1)
    
    -- Get preview window buffer
    local windows = vim.api.nvim_list_wins()
    local preview_buf = nil
    for _, win in ipairs(windows) do
      local buf = vim.api.nvim_win_get_buf(win)
      if buf ~= test_bufnr and vim.api.nvim_buf_is_valid(buf) then
        preview_buf = buf
        break
      end
    end
    
    eq(preview_buf ~= nil, true, 'Preview buffer should exist')
  end,

  'get_selected_buffer': function()
    ui.create_window(config)
    
    -- Move cursor to first line
    local list_win = vim.fn.bufwinid('bufflow')
    vim.api.nvim_win_set_cursor(list_win, {1, 0})
    
    local selected = ui.get_selected_buffer()
    eq(type(selected), 'table', 'Should return buffer info table')
    eq(type(selected.bufnr), 'number', 'Should have buffer number')
    eq(type(selected.name), 'string', 'Should have buffer name')
  end,
}

return new_set
