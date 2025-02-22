# nvim-bufflow

A Neovim plugin for efficient buffer management with preview functionality.

## Features

- Display buffer list
- Preview buffers while selecting
- Open selected buffer
- Delete selected buffer
- Bulk delete buffers (similar to quicker.nvim/oil.nvim)

## Architecture

### Core Components

1. **BufferManager**
   - Responsible for managing buffer operations
   - Methods:
     - `list_buffers()`: Get list of current buffers
     - `get_buffer_info(bufnr)`: Get detailed info about a buffer
     - `delete_buffer(bufnr)`: Delete a single buffer
     - `bulk_delete(bufnrs)`: Delete multiple buffers
     - `open_buffer(bufnr)`: Open a buffer

2. **UI Component**
   - Handles the buffer list display and preview window
   - Methods:
     - `create_window()`: Create the UI windows
     - `update_buffer_list()`: Update the buffer list display
     - `handle_preview()`: Handle buffer preview functionality
     - `close_windows()`: Close UI windows

3. **KeymapManager**
   - Manages keybindings for the plugin
   - Methods:
     - `setup_keymaps()`: Set up default keymaps
     - `handle_keymap(key)`: Handle keymap actions

### Implementation Plan

1. **Phase 1: Core Buffer Management**
   - Implement basic buffer operations
   - Create tests for buffer operations
   - Ensure proper error handling

2. **Phase 2: UI Implementation**
   - Create buffer list window
   - Implement preview functionality
   - Add basic navigation

3. **Phase 3: Advanced Features**
   - Implement bulk delete functionality
   - Add buffer filtering options
   - Enhance preview features

4. **Phase 4: Polish & Documentation**
   - Add comprehensive documentation
   - Optimize performance
   - Add configuration options

## File Structure

```
.
├── lua/
│   └── bufflow/
│       ├── init.lua
│       ├── buffer.lua
│       ├── ui.lua
│       └── keymap.lua
├── tests/
│   └── bufflow/
│       ├── buffer_spec.lua
│       ├── ui_spec.lua
│       └── keymap_spec.lua
└── docs/
    └── overview.md
```

## Testing Strategy

Using mini.test framework:

1. Unit Tests
   - Test buffer operations
   - Test UI window creation
   - Test keymap functionality

2. Integration Tests
   - Test buffer preview workflow
   - Test bulk delete operations
   - Test UI interactions

## Configuration Options

```lua
require('bufflow').setup({
  preview = {
    enabled = true,
    width = 0.5,  -- 50% of window width
    position = 'right'
  },
  keymaps = {
    close = 'q',
    delete = 'd',
    bulk_delete = 'D',
    preview = 'p',
    open = '<CR>'
  }
})
