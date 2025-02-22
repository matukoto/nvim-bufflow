# nvim-bufflow

A Neovim plugin for efficient buffer management with preview functionality.

## Features

- Display buffer list in a floating window
- Preview buffers while selecting
- Open selected buffer
- Delete single buffer
- Bulk delete multiple buffers
- Automatic preview on cursor movement

## Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use 'matukoto/nvim-bufflow'
```

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'matukoto/nvim-bufflow',
  config = function()
    require('bufflow').setup({
      -- your configuration here
    })
  end
}
```

## Usage

### Commands

- `:BufFlow` - Open buffer list window
- `:BufFlowClose` - Close buffer list window
- `:BufFlowDelete` - Delete current buffer

### Default Keymaps in Buffer List Window

- `q` - Close buffer list window
- `d` - Delete selected buffer
- `D` - Delete all selected buffers
- `p` - Preview selected buffer
- `<CR>` - Open selected buffer
- `<Space>` - Toggle buffer selection (for bulk delete)

## Configuration

```lua
require('bufflow').setup({
  preview = {
    enabled = true,      -- Enable/disable preview window
    width = 0.5,        -- Preview window width (0.0-1.0)
    position = 'right'  -- Preview window position ('right')
  },
  keymaps = {
    close = 'q',
    delete = 'd',
    bulk_delete = 'D',
    preview = 'p',
    open = '<CR>'
  }
})
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT
