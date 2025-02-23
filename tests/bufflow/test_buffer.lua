local T = require('mini.test')
local buffer = require('bufflow.buffer')

local new_set = T.new_set

local test_files = {
  'test1.txt',
  'test2.txt',
  'test3.txt',
}

-- Create test files
local function create_test_files()
  -- まず全てのバッファをクリーンアップ
  vim.cmd('silent! %bwipeout!')

  -- テストファイルを作成
  for _, file in ipairs(test_files) do
    -- 既存のファイルを削除
    os.remove(file)
    -- 新しいファイルを作成
    local f = io.open(file, 'w')
    if f then
      f:write('test content')
      f:close()
    end
  end

  -- バッファを作成
  for _, file in ipairs(test_files) do
    vim.cmd('badd ' .. file)
  end

  -- 最初のバッファに移動して内容を読み込む
  vim.cmd('buffer ' .. vim.fn.bufnr(test_files[1]))
  vim.cmd('edit')
end

-- Clean up test files
local function cleanup_test_files()
  -- まずバッファをクリーンアップ
  vim.cmd('silent! %bwipeout!')
  -- 次にファイルを削除
  for _, file in ipairs(test_files) do
    os.remove(file)
  end
end

-- Tests for buffer operations
local T = new_set({
  hooks = {
    pre_case = function()
      cleanup_test_files() -- クリーンアップを先に実行
      create_test_files()
    end,
    post_case = function()
      cleanup_test_files()
    end,
  },
})

T['list_buffers()'] = new_set()

T['list_buffers()']['returns list of buffers'] = function()
  local buffers = buffer.list_buffers()
  assert(type(buffers) == 'table', 'Expected buffers to be a table')
  assert(#buffers >= #test_files, 'Expected at least ' .. #test_files .. ' buffers')

  -- Check buffer structure
  local first_buffer = buffers[1]
  assert(type(first_buffer.id) == 'number', 'Expected id to be a number')
  assert(type(first_buffer.name) == 'string', 'Expected name to be a string')
  assert(type(first_buffer.path) == 'string', 'Expected path to be a string')
  assert(type(first_buffer.modified) == 'boolean', 'Expected modified to be a boolean')
  assert(type(first_buffer.filetype) == 'string', 'Expected filetype to be a string')
end

T['open_buffer()'] = new_set()

T['open_buffer()']['can open existing buffer'] = function()
  local buffers = buffer.list_buffers()
  local test_buffer = buffers[1]

  local success = buffer.open_buffer(test_buffer.id)
  assert(success == true, 'Expected open_buffer to return true')
  assert(
    vim.api.nvim_get_current_buf() == test_buffer.id,
    'Expected current buffer to be test buffer'
  )
end

T['open_buffer()']['returns false for non-existent buffer'] = function()
  local success = buffer.open_buffer(99999)
  assert(success == false, 'Expected open_buffer to return false for non-existent buffer')
end

T['delete_buffer()'] = new_set()

T['delete_buffer()']['can delete existing buffer'] = function()
  -- バッファの初期状態を確認
  local buffers = buffer.list_buffers()
  assert(#buffers > 0, 'Expected at least one buffer')
  local test_buffer = buffers[1]

  -- バッファが存在することを確認
  assert(vim.fn.bufexists(test_buffer.id) == 1, 'Buffer should exist before deletion')
  assert(vim.fn.buflisted(test_buffer.id) == 1, 'Buffer should be listed before deletion')

  -- バッファを削除
  local success = buffer.delete_buffer(test_buffer.id)
  assert(success, 'Expected delete_buffer to return true')

  -- バッファが削除されたことを確認
  assert(vim.fn.buflisted(test_buffer.id) == 0, 'Buffer should not be listed after deletion')
end

T['delete_buffer()']['returns false for non-existent buffer'] = function()
  local success = buffer.delete_buffer(99999)
  assert(not success, 'Expected delete_buffer to return false for non-existent buffer')
end

T['bulk_delete()'] = new_set()

T['bulk_delete()']['can delete multiple buffers'] = function()
  -- バッファの初期状態を確認
  local buffers = buffer.list_buffers()
  assert(#buffers >= 2, 'Expected at least two buffers')

  -- 削除するバッファを選択
  local buffer_ids = {
    buffers[1].id,
    buffers[2].id,
  }

  -- バッファが存在することを確認
  for _, bufnr in ipairs(buffer_ids) do
    assert(vim.fn.bufexists(bufnr) == 1, 'Buffer ' .. bufnr .. ' should exist before deletion')
    assert(vim.fn.buflisted(bufnr) == 1, 'Buffer ' .. bufnr .. ' should be listed before deletion')
  end

  -- バッファを一括削除
  local results = buffer.bulk_delete(buffer_ids)

  -- 削除結果を確認
  for _, bufnr in ipairs(buffer_ids) do
    assert(results[bufnr], 'Expected bulk_delete to return true for buffer ' .. bufnr)
    assert(
      vim.fn.buflisted(bufnr) == 0,
      'Buffer ' .. bufnr .. ' should not be listed after deletion'
    )
  end
end

return T
