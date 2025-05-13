local Log = {}

-- Size limit constant (false or -1 disables breaking)
local MAX_LINE_LENGTH = false

-- Get timestamp
Log.getLocalTime = function()
    local localTime = System.GetLocalOSTime()
    return string.format("%04d-%02d-%02d %02d:%02d:%02d",
            localTime.year + 1900, localTime.mon + 1, localTime.mday,
            localTime.hour, localTime.min, localTime.sec)
end

-- Simplified message building
local function buildMessage(args)
    local parts = {}
    for _, arg in ipairs(args) do
        if type(arg) == "table" then
            local items = {}
            for k, v in pairs(arg) do
                items[#items + 1] = tostring(k) .. "=" .. tostring(v)
            end
            parts[#parts + 1] = "{" .. table.concat(items, ",") .. "}"
        else
            parts[#parts + 1] = tostring(arg)
        end
    end
    return table.concat(parts, " "):gsub("%s+", " ")
end

-- Main logging function
Log._log = function(level, colorCode, ...)
    -- Check dependencies
    if not System or not System.LogAlways or not GearPicker or not GearPicker.MOD_NAME then
        return -- Silently fail if dependencies are missing
    end

    local timestamp = Log.getLocalTime()
    local modName = GearPicker.MOD_NAME
    local message = buildMessage({ ... })
    local prefix = string.format("%s[%s %s.%s] ", colorCode, timestamp, modName, level)
    local fullMessage = prefix .. message

    -- If MAX_LINE_LENGTH is false or -1, log full message without breaking
    if MAX_LINE_LENGTH == false or MAX_LINE_LENGTH == -1 then
        System.LogAlways(fullMessage)
    elseif #fullMessage <= MAX_LINE_LENGTH then
        System.LogAlways(fullMessage)
    else
        -- First line: exactly MAX_LINE_LENGTH
        local firstLine = fullMessage:sub(1, MAX_LINE_LENGTH)
        System.LogAlways(firstLine)

        -- Remaining message in chunks
        local remaining = fullMessage:sub(MAX_LINE_LENGTH + 1)
        local maxChunkLength = MAX_LINE_LENGTH - 5 -- Account for "    " indent
        while #remaining > 0 do
            local chunk = remaining:sub(1, maxChunkLength)
            if #chunk > 0 then
                System.LogAlways(colorCode .. "    " .. chunk)
            end
            remaining = remaining:sub(maxChunkLength + 1)
        end
    end
end

Log.info = function(...)
    if not GearPicker or not GearPicker:config() then
        return
    end

    local config = GearPicker:config()
    local isProd = config:isProduction()
    local isDebug = config:isDebug()

    if isProd and not isDebug then
        return
    end

    Log._log("INFO", "$5", ...)
end

Log.error = function(...)
    Log._log("ERROR", "$4", ...)
end

GearPicker.Log = Log

return Log