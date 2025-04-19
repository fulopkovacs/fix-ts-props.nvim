local M = {} -- M stands for module, a naming convention

local function get_current_node()
    -- Get the current buffer
    local bufnr = vim.api.nvim_get_current_buf()

    -- Get cursor position (row, col)
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row = cursor[1] - 1 -- Convert to 0-based index
    local col = cursor[2]

    -- Get parser and tree root
    local parser = vim.treesitter.get_parser(bufnr)
    if parser == nil then
        -- print("X Parser is nil")
        return nil
    end
    local tree = parser:parse()[1]
    local root = tree:root()

    -- Get node at cursor
    local node = vim.treesitter.get_node({
        row, col,
    })

    if node then
        return node
    else
        return nil
    end
end

---@param node TSNode TreeSitter node
---@return TSNode|nil The parameters node or nil if not found
local function get_param_node(node)
    if node:type() ~= "required_parameter" then
        local parent = node:parent()
        if parent then
            return get_param_node(parent)
        else
            return nil
        end
    end

    -- print(node:type())
    return node
end

---@param node TSNode TreeSitter node
---@return { property_names: string[], end_pos: {row: number, col: number} }|nil
local function get_the_property_names(node)
    if node:named_child_count() == 0 then
        -- print("No named children")
        local _, _, end_row, end_col = node:range()

        return {
            property_names = {},
            end_pos = {
                row = end_row,
                col = end_col - 1,
            },

        }
    end

    -- @type string[]
    local known_prop_names = {}

    -- @type TSNode
    local last_property_node

    for _, child_node in ipairs(node:named_children()) do
        if child_node:type() ~= "shorthand_property_identifier_pattern" then
            -- Probably a rest pattern_node
            -- print("Unexpexted node type was found: " .. child_node:type())
            return nil
        end

        table.insert(known_prop_names, vim.treesitter.get_node_text(child_node, 0))
        -- known_prop_names[#known_prop_names + 1] = vim.treesitter.get_node_text(child_node, 0)
        last_property_node = child_node
    end

    -- print(vim.inspect(known_prop_names))

    local _, _, end_row, end_col = last_property_node:range()
    return {
        property_names = known_prop_names,
        end_pos = {
            row = end_row,
            col = end_col,
        },
    }
end

---@param param_node TSNode TreeSitter node
---@return { object_pattern_node: TSNode, object_type_node: TSNode }|nil # Returns a table containing the object pattern and type nodes, or nil if the required nodes are not found
local function get_props_and_type_nodes(param_node)
    -- NOTE: this should never happen
    if param_node:named_child_count() == 0 then
        print("No named children")
        return nil
    end

    local first_named_child = param_node:named_child(0)
    local second_named_child_node = param_node:named_child(1)
    if first_named_child and first_named_child:type() == "object_pattern" and second_named_child_node and second_named_child_node:type() ==
        "type_annotation" then
        return {
            object_pattern_node = first_named_child,
            object_type_node = second_named_child_node,

        }
    end
    return nil

end

---@param node TSNode TreeSitter node
---@return string[] |nil # A list of the names that are in the type definition
local function get_typed_property_names(node)
    if node:named_child_count() == 0 then
        -- print("No named children")
        return nil
    end

    -- @type string[]
    local props_in_type = {}

    local object_type_node = node:named_child(0)
    if object_type_node and object_type_node:type() == "object_type" then
        for _, child_node in ipairs(object_type_node:named_children()) do
            -- known_prop_names[#known_prop_names + 1] = vim.treesitter.get_node_text(child_node, 0)
            -- Get property identifier
            if child_node:type() == "property_signature" then
                for _, child_child_node in ipairs(child_node:named_children()) do
                    if child_child_node:type() == "property_identifier" then
                        table.insert(props_in_type, vim.treesitter.get_node_text(child_child_node, 0))
                        -- props_in_type[#props_in_type + 1] = vim.treesitter.get_node_text(child_child_node, 0)
                        break
                    end
                end
            end
        end

    end

    return props_in_type
end

-- Get the list of the property names that exist in the type
-- definition, but missing from the object pattern.
---@param prop_names_in_object_pattern string[] Array of property names from the object pattern
---@param prop_names_in_type string[] Array of property names from the type definition
---@return string[] # Returns array of property names that exist in type but not in object pattern
local function get_list_of_missing_prop_names(prop_names_in_object_pattern, prop_names_in_type)
    local missing_props = {}

    for _, type_prop in ipairs(prop_names_in_type) do
        local found = false
        for _, pattern_prop in ipairs(prop_names_in_object_pattern) do
            if type_prop == pattern_prop then
                found = true
                break
            end
        end
        if not found then
            table.insert(missing_props, type_prop)
        end
    end

    return missing_props
end

---@param missing_props string[]
---@param initial_comma boolean
---@param insert_pos {row: number, col: number}
local function insert_missing_prop_names(missing_props, initial_comma, insert_pos)
    if #missing_props == 0 then
        return nil
    end

    -- local _, _, end_row, end_col = last_property_node:range()
    local end_row = insert_pos.row
    local end_col = insert_pos.col
    local start_text = ", "
    if initial_comma == false then
        start_text = ""
    end
    local text_to_insert = start_text .. table.concat(missing_props, ", ")

    -- Insert text after the last property
    vim.api.nvim_buf_set_text(0, end_row, end_col, end_row, end_col, {
        text_to_insert,
    })
end

M.fix_missing_ts_props = function()
    local current_node = get_current_node()
    if current_node == nil then
        -- print("current_node is nil")
        return nil
    end
    local param_node = get_param_node(current_node)
    if param_node == nil then
        -- print("param node is nil")
        return nil
    end
    local propsAndTypeNodes = get_props_and_type_nodes(param_node)
    if (propsAndTypeNodes == nil) then
        -- print("props and type nodes are not found")
        return nil
    end
    local property_names_and_last_node = get_the_property_names(propsAndTypeNodes.object_pattern_node)
    local typed_property_names = get_typed_property_names(propsAndTypeNodes.object_type_node)
    if (property_names_and_last_node == nil or typed_property_names == nil) then
        return nil
    end
    local missing_props = get_list_of_missing_prop_names(property_names_and_last_node.property_names, typed_property_names)
    insert_missing_prop_names(missing_props, #property_names_and_last_node.property_names > 0, property_names_and_last_node.end_pos)

end

-- function M.setup()
--     print("hello")
-- end

return M
