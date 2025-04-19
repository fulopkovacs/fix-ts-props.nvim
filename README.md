# fix-ts-props.nvim

> **This plugin is a work in progress!** I don't recommend using it... ^^

A Neovim plugin that automatically fixes missing TypeScript props in React
components.

## Features

- Automatically adds missing props from TypeScript interfaces to component
  destructuring patterns
- Supports React functional components
- Uses Treesitter for accurate TypeScript parsing

## Requirements

- Neovim >= 0.5.0
- Treesitter with TypeScript parser installed

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    'fulopkovacs/fix-ts-props.nvim',
    ft = { 'typescript', 'typescriptreact' }
}
```

## Usage

1. Place your cursor within a React component's props parameter
2. Call the `fix_missing_ts_props` function:

```lua
:lua require('fix-ts-props').fix_missing_ts_props()
```

### Recommended Configuration

Add this to your Neovim configuration:

```lua
vim.keymap.set('n', '<Leader>fp', require('fix-ts-props').fix_missing_ts_props, { desc = 'Fix TypeScript Props' })
```

## Examples

Before:

```typescript
function Component({name}: {name: string; age: number}) {
  return <div>{name}</div>
}
```

After:

```typescript
function Component({name, age}: {name: string; age: number}) {
  return <div>{name}</div>
}
```

## License

MIT
