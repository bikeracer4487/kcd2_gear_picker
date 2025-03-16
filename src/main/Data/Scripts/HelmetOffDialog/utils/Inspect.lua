Inspect = Inspect or {}

function Inspect.table(env_table, log_prefix)
    log_prefix = log_prefix or "Table"

    -- Check if env_table is nil
    if env_table == nil then
        System.LogAlways(log_prefix .. " is nil")
        return
    end

    -- Verify env_table is a table
    if type(env_table) ~= "table" then
        System.LogAlways(log_prefix .. " is not a table, type: " .. type(env_table))
        return
    end

    -- Collect direct keys
    local direct_keys = {}
    for key, value in pairs(env_table) do
        table.insert(direct_keys, tostring(key))
    end
    System.LogAlways(log_prefix .. " direct keys: " .. (next(direct_keys) and table.concat(direct_keys, ", ") or "none"))

    -- Check for metatable and its __index
    local mt = getmetatable(env_table)
    if mt and mt.__index then
        local mt_keys = {}
        for key, value in pairs(mt.__index) do
            table.insert(mt_keys, tostring(key))
        end
        System.LogAlways(log_prefix .. " metatable keys: " .. (next(mt_keys) and table.concat(mt_keys, ", ") or "none"))
    else
        System.LogAlways(log_prefix .. " has no metatable or __index")
    end
end

Inspect = Inspect or {}

-- Shared core search logic
local function search_table_core(tbl, search_term, prefix, depth, visited, table_name, is_case_sensitive, log_matches)
    if visited[tbl] then return end
    visited[tbl] = true
    depth = depth or 0

    for key, value in pairs(tbl) do
        local key_str = tostring(key)
        local key_to_compare = is_case_sensitive and key_str or string.lower(key_str)
        local current_path = prefix .. (prefix ~= "" and "." or "") .. key_str

        if key_to_compare:find(search_term) then
            log_matches(current_path, depth, key_str, value)
        end

        if type(value) == "table" then
            search_table_core(value, search_term, current_path, depth + 1, visited, table_name, is_case_sensitive, log_matches)
        end
    end

    local mt = getmetatable(tbl)
    if mt and mt.__index and type(mt.__index) == "table" then
        search_table_core(mt.__index, search_term, prefix .. ".[metatable]", depth + 1, visited, table_name, is_case_sensitive, log_matches)
    end
end

-- Case-insensitive search
function Inspect.search_table_by_key_ci(env_table, search_term, table_name)
    search_term = string.lower(search_term or "map")

    if env_table == nil then
        System.LogAlways("Table " .. tostring(env_table) .. " is nil")
        return
    end

    if type(env_table) ~= "table" then
        System.LogAlways("Table " .. tostring(env_table) .. " is not a table, type: " .. type(env_table))
        return
    end

    local visited = {}
    local found_match = false

    local function log_matches(path, depth, key, value)
        if not found_match then
            System.LogAlways("Searching " .. table_name .. " for keys containing '" .. search_term .. "' (case-insensitive)")
            found_match = true
        end
        System.LogAlways(string.format("%s[depth %d] Found match: %s = %s", path, depth, key, tostring(value)))
    end

    search_table_core(env_table, search_term, table_name, 0, visited, table_name, false, log_matches)
end

-- Case-sensitive search
function Inspect.search_table_by_key_cs(env_table, search_term, table_name)
    search_term = search_term or "map"

    if env_table == nil then
        System.LogAlways("Table " .. tostring(env_table) .. " is nil")
        return
    end

    if type(env_table) ~= "table" then
        System.LogAlways("Table " .. tostring(env_table) .. " is not a table, type: " .. type(env_table))
        return
    end

    local visited = {}
    local found_match = false

    local function log_matches(path, depth, key, value)
        if not found_match then
            System.LogAlways("Searching " .. table_name .. " for keys containing '" .. search_term .. "' (case-sensitive)")
            found_match = true
        end
        System.LogAlways(string.format("%s[depth %d] Found match: %s = %s", path, depth, key, tostring(value)))
    end

    search_table_core(env_table, search_term, table_name, 0, visited, table_name, true, log_matches)
end

function Inspect.table_deep(env_table, log_prefix, level, visited)
    -- Default parameters
    log_prefix = log_prefix or "Table"
    level = level or 0
    visited = visited or {}

    -- Indentation for tree-like structure
    local indent = string.rep("  ", level)

    -- Check if env_table is nil
    if env_table == nil then
        System.LogAlways(indent .. log_prefix .. ": nil")
        return
    end

    -- Get the type of env_table
    local env_type = type(env_table)

    -- Verify env_table is actually a table or has a metatable we can inspect
    if env_type ~= "table" then
        -- Handle functions and other types explicitly
        System.LogAlways(indent .. log_prefix .. ": " .. env_type .. " (" .. tostring(env_table) .. ")")

        -- Check for metatable even on non-tables
        local mt = getmetatable(env_table)
        if mt then
            System.LogAlways(indent .. "Metatable:")
            if type(mt) == "table" then
                Inspect.table_deep(mt, "mt", level + 1, visited)
            else
                System.LogAlways(indent .. "  " .. tostring(mt))
            end
        end
        return
    end

    -- Check for circular reference
    if visited[env_table] then
        System.LogAlways(indent .. log_prefix .. ": [Circular Reference]")
        return
    end
    visited[env_table] = true

    -- Print table header
    System.LogAlways(indent .. log_prefix .. ":")

    -- Safely iterate through table contents
    local success, err = pcall(function()
        for key, value in pairs(env_table) do
            local key_str = tostring(key)
            local value_type = type(value)

            if value_type == "table" then
                -- Recursively inspect nested tables
                Inspect.table_deep(value, "[" .. key_str .. "]", level + 1, visited)
            else
                -- Print non-table values directly
                System.LogAlways(indent .. "  [" .. key_str .. "]: " .. value_type .. " (" .. tostring(value) .. ")")
            end
        end
    end)

    if not success then
        System.LogAlways(indent .. "  [Error iterating table: " .. tostring(err) .. "]")
    end

    -- Check and display metatable if it exists
    local mt = getmetatable(env_table)
    if mt then
        System.LogAlways(indent .. "Metatable:")
        if type(mt) == "table" then
            Inspect.table_deep(mt, "mt", level + 1, visited)
        else
            System.LogAlways(indent .. "  " .. tostring(mt))
        end
    end
end


function Inspect.table_deep_json(env_table, log_prefix, level, visited)
    -- Default parameters
    log_prefix = log_prefix or "Table"
    level = level or 0
    visited = visited or {}

    -- Indentation helper
    local function indent(n)
        return string.rep("  ", n)
    end

    -- Escape string for JSON
    local function escape_str(s)
        return '"' .. tostring(s):gsub('"', '\\"') .. '"'
    end

    -- Check if env_table is nil
    if env_table == nil then
        System.LogAlways(indent(level) .. '{')
        System.LogAlways(indent(level + 1) .. '"name": ' .. escape_str(log_prefix) .. ',')
        System.LogAlways(indent(level + 1) .. '"type": "nil",')
        System.LogAlways(indent(level + 1) .. '"value": "nil",')
        System.LogAlways(indent(level + 1) .. '"level": ' .. level)
        System.LogAlways(indent(level) .. '}')
        return
    end

    -- Get the type of env_table
    local env_type = type(env_table)

    -- Handle non-table types
    if env_type ~= "table" then
        System.LogAlways(indent(level) .. '{')
        System.LogAlways(indent(level + 1) .. '"name": ' .. escape_str(log_prefix) .. ',')
        System.LogAlways(indent(level + 1) .. '"type": ' .. escape_str(env_type) .. ',')
        System.LogAlways(indent(level + 1) .. '"value": ' .. escape_str(tostring(env_table)) .. ',')
        System.LogAlways(indent(level + 1) .. '"level": ' .. level)

        local mt = getmetatable(env_table)
        if mt then
            System.LogAlways(indent(level + 1) .. '"metatable": ' .. (type(mt) == "table" and "" or '{'))
            if type(mt) == "table" then
                Inspect.table_deep_json(mt, "mt", level + 1, visited)
            else
                System.LogAlways(indent(level + 2) .. '"name": "mt",')
                System.LogAlways(indent(level + 2) .. '"type": ' .. escape_str(type(mt)) .. ',')
                System.LogAlways(indent(level + 2) .. '"value": ' .. escape_str(tostring(mt)) .. ',')
                System.LogAlways(indent(level + 2) .. '"level": ' .. (level + 1))
                System.LogAlways(indent(level + 1) .. '}')
            end
            System.LogAlways(indent(level) .. '}')
        else
            System.LogAlways(indent(level) .. '}')
        end
        return
    end

    -- Check for circular reference
    if visited[env_table] then
        System.LogAlways(indent(level) .. '{')
        System.LogAlways(indent(level + 1) .. '"name": ' .. escape_str(log_prefix) .. ',')
        System.LogAlways(indent(level + 1) .. '"type": "table",')
        System.LogAlways(indent(level + 1) .. '"isCircular": true,')
        System.LogAlways(indent(level + 1) .. '"value": "[Circular Reference]",')
        System.LogAlways(indent(level + 1) .. '"level": ' .. level)
        System.LogAlways(indent(level) .. '}')
        return
    end
    visited[env_table] = true

    -- Print table structure
    System.LogAlways(indent(level) .. '{')
    System.LogAlways(indent(level + 1) .. '"name": ' .. escape_str(log_prefix) .. ',')
    System.LogAlways(indent(level + 1) .. '"type": "table",')
    System.LogAlways(indent(level + 1) .. '"level": ' .. level .. ',')
    System.LogAlways(indent(level + 1) .. '"children": [')

    local first_child = true
    local success, err = pcall(function()
        for key, value in pairs(env_table) do
            if not first_child then
                System.LogAlways(indent(level + 1) .. ',')
            end
            first_child = false

            local key_str = "[" .. tostring(key) .. "]"
            local value_type = type(value)

            if value_type == "table" then
                Inspect.table_deep_json(value, key_str, level + 1, visited)
            else
                System.LogAlways(indent(level + 2) .. '{')
                System.LogAlways(indent(level + 3) .. '"name": ' .. escape_str(key_str) .. ',')
                System.LogAlways(indent(level + 3) .. '"type": ' .. escape_str(value_type) .. ',')
                System.LogAlways(indent(level + 3) .. '"value": ' .. escape_str(tostring(value)) .. ',')
                System.LogAlways(indent(level + 3) .. '"level": ' .. (level + 1))
                System.LogAlways(indent(level + 2) .. '}')
            end
        end
    end)

    if not success then
        if not first_child then
            System.LogAlways(indent(level + 1) .. ',')
        end
        System.LogAlways(indent(level + 2) .. '{')
        System.LogAlways(indent(level + 3) .. '"name": "[Error]",')
        System.LogAlways(indent(level + 3) .. '"type": "error",')
        System.LogAlways(indent(level + 3) .. '"value": ' .. escape_str(tostring(err)) .. ',')
        System.LogAlways(indent(level + 3) .. '"level": ' .. (level + 1))
        System.LogAlways(indent(level + 2) .. '}')
    end

    System.LogAlways(indent(level + 1) .. ']')

    -- Add metatable if present
    local mt = getmetatable(env_table)
    if mt then
        System.LogAlways(indent(level + 1) .. ',"metatable": ' .. (type(mt) == "table" and "" or '{'))
        if type(mt) == "table" then
            Inspect.table_deep_json(mt, "mt", level + 1, visited)
        else
            System.LogAlways(indent(level + 2) .. '"name": "mt",')
            System.LogAlways(indent(level + 2) .. '"type": ' .. escape_str(type(mt)) .. ',')
            System.LogAlways(indent(level + 2) .. '"value": ' .. escape_str(tostring(mt)) .. ',')
            System.LogAlways(indent(level + 2) .. '"level": ' .. (level + 1))
            System.LogAlways(indent(level + 1) .. '}')
        end
    end

    System.LogAlways(indent(level) .. '}')
end

-- Example usage:
-- local test = {a = 1, b = {x = "test"}, c = function() end}
-- Inspect.table_deep_json(test)