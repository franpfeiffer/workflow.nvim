# workflow.nvim
workflow.nvim us an plugin to create and manage ASCII diagrams directly in neovim.

## Features

- 📦 Create boxes and containers with customizable dimensions
- ➡️ Draw arrows in multiple directions (horizontal, vertical, diagonal)
- 📐 Resize and reposition diagram elements
- 🔧 Built-in diagram templates
- 🎨 DSL support for complex diagram creation
- 📤 Export diagrams to Markdown
- ⌨️ Intuitive key mappings


## Installation

```lua
use {
    'franpfeiffer/workflow.nvim',
    config = function()
        require('workflow').setup({
            -- optional configuration
        })

    end
}
```

Using [lazy.nvim](https://github.com/folke/lazy.nvim):
```lua
{
    'franpfeiffer/workflow.nvim',
    config = function()
        require('workflow').setup()
    end
}
```

## Configuration

```lua
require('workflow').setup({
    default_box_width = 7,      -- Default width for boxes
    default_arrow_style = "-->", -- Default arrow style
    templates = {               -- Add custom templates
        my_template = [[
            +-----+
            | Box |
            +-----+
        ]]
    }
})
```

## Usage

### Basic Commands

- `:AsciiBox` - Create a box
```
+-------+
|       |
+-------+
```

- `:AsciiArrow [direction]` - Create an arrow (horizontal, vertical, diagonal)
```
Horizontal: ───►

Vertical:   │
            ▼
Diagonal:   ╲
            ╲
```

- `:AsciiResize` - Resize the current box (prompts for dimensions)
- `:AsciiTemplate [name]` - Apply a predefined template
- `:AsciiGenerate [register]` - Generate diagram from DSL
- `:AsciiExport` - Export diagram to Markdown

### Using Templates

Built-in templates:

1. Flow Template (`:AsciiTemplate flow`):
```
+-------+    +-------+
| Start | -->| End   |
+-------+    +-------+
```

2. Decision Template (`:AsciiTemplate decision`):

```
    +-------+
    | Start |
    +-------+
        │
    +-------+
    | Check |
    +-------+
     ╱     ╲
+---+     +---+
|Yes|     |No |
+---+     +---+
```

### DSL (Domain Specific Language)

Create diagrams using simple text commands:

```
box "Start"
arrow
box "Process"
arrow
box "End"
```

To use the DSL:
1. Copy your DSL commands to a register (e.g., register 'a')
2. Run `:AsciiGenerate a`

### Exporting

Export your diagrams to Markdown:
1. Create your diagram
2. Run `:AsciiExport`
3. Enter filename (defaults to diagram.md)

The diagram will be exported as a markdown code block:

```ascii
+-------+    +-------+
| Start | -->| End   |
+-------+    +-------+
```

## Examples

### Creating a Simple Flow


```lua
-- Create a flow diagram using commands
:AsciiBox
-- Move cursor down
:AsciiArrow
-- Move cursor down
:AsciiBox


-- Result:
+-------+
|       |
+-------+
   ───►
+-------+
|       |
+-------+
```

### Using DSL for Complex Diagrams

```
-- Copy to register 'a':
box "Input"
arrow
box "Process"
arrow "vertical"
box "Output"


-- Generate using:
:AsciiGenerate a

-- Result:
+-------+
| Input |
+-------+
   ───►
+-------+
|Process|
+-------+
    │
    ▼
+-------+
|Output |
+-------+
```
