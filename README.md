# lua-repl.nvim

A Neovim plugin that provides a Lua REPL (Read-Eval-Print Loop) environment designed to evaluate Lua code, including Neovim-specific Lua functions. This allows you to interactively test and execute Lua code, including Neovim's API functions, inside Neovim.

This plugin was created for personal use and is not particularly optimized for general usability or convenience. It serves as a basic REPL within Neovim to test Lua code interactively.

https://github.com/user-attachments/assets/e6852a42-1fbd-4777-8d18-8e8ddacd48c2

## Features

- **Interactive Lua REPL**: Write, execute, and evaluate Lua code directly within Neovim.
- **Neovim-Specific API Access**: Evaluate Lua code that uses Neovim's built-in functions and APIs, such as `vim.api`, `vim.fn`, and `vim.inspect`.

## Installation

lazy.nvim:

```lua
{
  'goropikari/lua-repl.nvim',
  config = true,
  cmd = { 'LuaREPL' },
},
```

## Usage

### Commands

- `:LuaREPL`: Toggle the Lua REPL interface, opening the prompt and viewer windows.

### Key Mappings

#### In the **prompt** buffer:
- `<Ctrl-s>`: Execute the Lua code in the prompt buffer and display the output in the viewer buffer.
- `q`: Close the REPL interface (both prompt and viewer windows).

#### In the **viewer** buffer:
- `q`: Close the REPL interface.

### Example Workflow

1. Open the Lua REPL interface with `:LuaREPL`.
2. In the **prompt** buffer (left window), write your Lua code. You can use Neovim-specific Lua functions.
3. Press `<Ctrl-s>` to execute the code. The output will be displayed in the **viewer** buffer (right window).
4. Press `q` to close the REPL when done.

## License

This plugin is licensed under the MIT License.
