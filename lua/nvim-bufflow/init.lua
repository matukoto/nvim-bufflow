local M = {}
local keymap = require('nvim-bufflow.keymap')
local ui = require('nvim-bufflow.ui')

-- デフォルトの設定
local default_config = {
  -- キーマップの設定
  keymap = {
    close = 'q', -- バッファリストを閉じる
    delete = 'd', -- バッファを削除
    bulk_delete = 'D', -- 選択したバッファを一括削除
    preview = 'p', -- プレビューの切り替え
    open = '<CR>', -- バッファを開く
  },
  -- ウィンドウの設定
  window = {
    preview_enabled = true, -- プレビューウィンドウを有効にする
    preview_width = 0.5, -- プレビューウィンドウの幅（割合）
    preview_position = 'right', -- プレビューウィンドウの位置
  },
}

-- プラグインの設定
---@param config table オプションの設定テーブル
function M.setup(config)
  -- 設定のマージ
  config = vim.tbl_deep_extend('force', default_config, config or {})

  -- バッファリストコマンドの登録
  vim.api.nvim_create_user_command('Bufflow', function()
    ui.create_window(config.window)
    keymap.setup(config.keymap)
  end, {})

  -- バッファ一括削除コマンドの登録
  vim.api.nvim_create_user_command('BufflowDelete', function()
    -- 現在のバッファを保持
    local current_buf = vim.api.nvim_get_current_buf()

    -- すべてのバッファをリスト化
    local buffers = vim.tbl_filter(function(b)
      return vim.fn.buflisted(b) == 1 and b ~= current_buf
    end, vim.api.nvim_list_bufs())

    -- バッファを一括削除
    for _, bufnr in ipairs(buffers) do
      pcall(vim.cmd, string.format('bdelete! %d', bufnr))
    end
  end, {})
end

return M
