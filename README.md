# nvim-bufflow

[![CI](https://github.com/matukoto/nvim-bufflow/actions/workflows/ci.yml/badge.svg)](https://github.com/matukoto/nvim-bufflow/actions/workflows/ci.yml)

Neovimのバッファ管理プラグイン。プレビュー機能付きでバッファの閲覧、切り替え、削除が可能です。

## 機能

- バッファ一覧の表示
- プレビュー機能付きのバッファ選択
- バッファの開閉操作
- 単一または一括でのバッファ削除

## インストール

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'matukoto/nvim-bufflow',
  config = function()
    require('bufflow').setup({
      -- オプション設定
    })
  end,
}
```

## 設定

デフォルト設定:

```lua
require('bufflow').setup({
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
})
```

## 使い方

### コマンド

- `:Bufflow` - バッファリストを開く
- `:BufflowDelete` - 現在のバッファ以外をすべて削除

### キーマップ（デフォルト）

バッファリストウィンドウ内で:

- `q` - バッファリストを閉じる
- `d` - カーソル位置のバッファを削除
- `D` - 選択したバッファを一括削除
- `p` - プレビューウィンドウの表示/非表示を切り替え
- `<CR>` - カーソル位置のバッファを開く

## 貢献

バグ報告や機能リクエストは[GitHub Issues](https://github.com/matukoto/nvim-bufflow/issues)にお願いします。

## ライセンス

MIT License
