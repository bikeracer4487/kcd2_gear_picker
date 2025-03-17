-- Helper function to dump a variable with indentation
local function dumpVar(var, indent, visited)
    indent = indent or 0
    visited = visited or {} -- Track visited tables to avoid cycles
    local indentStr = string.rep("  ", indent)
    local output = {}

    if type(var) == "table" then
        if visited[var] then
            table.insert(output, indentStr .. "[circular reference]")
        else
            visited[var] = true
            table.insert(output, indentStr .. "{")
            for k, v in pairs(var) do
                local keyStr = type(k) == "string" and k or "[" .. tostring(k) .. "]"
                table.insert(output, indentStr .. "  " .. keyStr .. " = " .. dumpVar(v, indent + 1, visited))
            end
            table.insert(output, indentStr .. "}")
        end
    elseif type(var) == "string" then
        table.insert(output, indentStr .. "\"" .. var .. "\"")
    elseif type(var) == "nil" then
        table.insert(output, indentStr .. "nil") -- Explicitly show nil
    elseif type(var) == "function" then
        table.insert(output, indentStr .. "function: not inspected") -- Explain functions
    else
        table.insert(output, indentStr .. tostring(var))
    end

    return table.concat(output, "\n")
end

-- Main dd function
function dd(...)
    local args = {...}
    local output = {}

    -- If no arguments are passed, report it
    if #args == 0 then
        table.insert(output, "[DD] No arguments provided")
    else
        for i, arg in ipairs(args) do
            table.insert(output, "[DD] Argument " .. i .. ":")
            table.insert(output, dumpVar(arg))
        end
    end

    local fullOutput = table.concat(output, "\n")

    -- Debug: Print the output and its length
    print("DEBUG: fullOutput length = " .. #fullOutput)
    print(fullOutput)

    -- Fallback if System.LogAlways exists
    if System and System.LogAlways then
        System.LogAlways("DEBUG: fullOutput length = " .. #fullOutput)
        System.LogAlways(fullOutput)
    end

    -- Raise error with the full output, even if it’s just "nil"
    error(fullOutput, 0)
end