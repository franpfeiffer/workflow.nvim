local M = {}

local config = {
    default_box_width = 7,
    default_arrow_style = "-->",
    templates = {},
}

M.setup = function(opts)
    config = vim.tbl_deep_extend("force", config, opts or {})
    M.create_commands()
end

local function create_box(width, height, text)
    local top = "+" .. string.rep("-", width) .. "+"
    local middle = "|" .. string.rep(" ", width) .. "|"
    local content = text and ("| " .. text .. string.rep(" ", width - #text - 1) .. "|") or middle
    local bottom = top
    local lines = {top}
    for _ = 1, (height or 1) - 2 do
        table.insert(lines, content)
    end
    table.insert(lines, bottom)
    return lines
end


local function create_arrow(direction)
    if direction == "vertical" then
        return {"│", "▼"}
    elseif direction == "diagonal" then
        return {"╲", " ╲"}
    else
        return {"───►"}
    end
end

M.create_box = function()
    local lines = create_box(config.default_box_width, 3)
    vim.api.nvim_put(lines, "l", true, true)
end

M.create_arrow = function(opts)
    local direction = opts.args or "horizontal"
    local arrow = create_arrow(direction)
    vim.api.nvim_put(arrow, "l", true, true)
end

M.resize_box = function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local width = tonumber(vim.fn.input("Width: ")) or config.default_box_width
    local height = tonumber(vim.fn.input("Height: ")) or 3
    local lines = create_box(width, height)
    local start_line = cursor[1] - 1
    vim.api.nvim_buf_set_lines(0, start_line, start_line + #lines, false, lines)
end

M.add_template = function(name, content)
    config.templates[name] = content
end

M.apply_template = function(name)
    local template = config.templates[name]
    if not template then
        vim.notify("Template not found: " .. name, vim.log.levels.ERROR)
        return
    end
    vim.api.nvim_put(vim.split(template, "\n"), "l", true, true)
end

local function parse_dsl(input)
    local elements = {}
    for line in input:gmatch("[^\r\n]+") do
        local cmd, arg = line:match("(%w+)%s*\"(.-)\"")
        if cmd == "box" then
            table.insert(elements, create_box(config.default_box_width, 3, arg))
        elseif cmd == "arrow" then
            table.insert(elements, create_arrow(arg or "horizontal"))
        end
    end
    return elements
end

M.generate_from_dsl = function(input)

    local elements = parse_dsl(input)
    local result = {}
    for _, element in ipairs(elements) do
        vim.list_extend(result, element)
    end
    vim.api.nvim_put(result, "l", true, true)
end

M.export_markdown = function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local markdown = "```ascii\n" .. table.concat(lines, "\n") .. "\n```"
    local filename = vim.fn.input("Export to file (default: diagram.md): ")
    filename = filename ~= "" and filename or "diagram.md"
    local ok, err = pcall(vim.fn.writefile, vim.split(markdown, "\n"), filename)
    if not ok then
        vim.notify("Failed to export: " .. err, vim.log.levels.ERROR)
        return
    end
    vim.notify("Diagram exported to " .. filename)
end

M.create_commands = function()
    local commands = {
        AsciiBox = {M.create_box, {}},
        AsciiArrow = {M.create_arrow, {nargs = "?"}},
        AsciiResize = {M.resize_box, {}},
        AsciiTemplate = {function(opts) M.apply_template(opts.args) end, {nargs = 1}},
        AsciiGenerate = {function(opts) M.generate_from_dsl(vim.fn.getreg(opts.args)) end, {nargs = 1}},
        AsciiExport = {M.export_markdown, {}}
    }
    for name, cmd in pairs(commands) do
        vim.api.nvim_create_user_command(name, cmd[1], cmd[2])
    end
end

M.add_template("flow", [[
+-------+     +-------+
| Start | --> | End   |
+-------+     +-------+
]])

M.add_template("decision", [[

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
  │         │
+----+   +----+
|smth|   |smth|
+----+   +----+

]])

return M
