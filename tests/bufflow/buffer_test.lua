local eq = assert.are.same
local T = require('mini.test')

local buffer = require('bufflow.buffer')

local test_file = 'test_buffer.txt'

local new_set = MiniTest.new_set {
  hooks = {
    pre_case = function()
      -- Create test buffer
      vim.cmd('new ' .. test_file)
    end,
    post_case = function()
      -- Clean up test buffer
      vim.cmd('bdelete! ' .. test_file)
    end,
  },
}

new_set {
  'list_buffers': function()
    local buffers = buffer.list_buffers()
    eq(type(buffers), 'table', 'Should return a table of buffers')
    eq(#buffers > 0, true, 'Should have at least one buffer')

    local found_test_buffer = false
    for _, buf in ipairs(buffers) do
      if buf.name:match(test_file) then
        found_test_buffer = true
        break
      end
    end
    eq(found_test_buffer, true, 'Should include the test buffer')
  end,

  'get_buffer_info': function()
    local bufnr = vim.fn.bufnr(test_file)
    local info = buffer.get_buffer_info(bufnr)

    eq(type(info), 'table', 'Should return a table')
    eq(info.bufnr, bufnr, 'Should have correct buffer number')
    eq(type(info.name), 'string', 'Should have a name')
    eq(type(info.modified), 'boolean', 'Should have modified status')
    eq(type(info.listed), 'boolean', 'Should have listed status')
  end,

  'delete_buffer': function()
    local bufnr = vim.fn.bufnr(test_file)
    local success = buffer.delete_buffer(bufnr)
    
    eq(success, true, 'Should successfully delete buffer')
    eq(vim.api.nvim_buf_is_valid(bufnr), false, 'Buffer should no longer be valid')
  end,

  'bulk_delete': function()
    -- Create additional test buffer
    vim.cmd('new test_buffer2.txt')
    local bufnr1 = vim.fn.bufnr(test_file)
    local bufnr2 = vim.fn.bufnr('test_buffer2.txt')
    
    local results = buffer.bulk_delete({ bufnr1, bufnr2 })
    
    eq(#results, 2, 'Should return results for both buffers')
    eq(results[1], true, 'First buffer should be deleted')
    eq(results[2], true, 'Second buffer should be deleted')
    eq(vim.api.nvim_buf_is_valid(bufnr1), false, 'First buffer should be invalid')
    eq(vim.api.nvim_buf_is_valid(bufnr2), false, 'Second buffer should be invalid')
  end,

  'open_buffer': function()
    local bufnr = vim.fn.bufnr(test_file)
    local success = buffer.open_buffer(bufnr)
    
    eq(success, true, 'Should successfully open buffer')
    eq(vim.api.nvim_get_current_buf(), bufnr, 'Should set as current buffer')
  end,
}

return new_set
