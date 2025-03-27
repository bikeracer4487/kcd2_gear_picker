local Log = {
    getLocalTime = function()
        local localTime = System.GetLocalOSTime()
        return string.format("%04d-%02d-%02d %02d:%02d:%02d",
                localTime.year + 1900, localTime.mon + 1, localTime.mday,
                localTime.hour, localTime.min, localTime.sec)
    end,
    _log = function(level, colorCode, ...)
        local localTime = Log.getLocalTime()
        local args = { ... }
        local messageParts = {}

        for _, arg in ipairs(args) do
            if type(arg) == "table" then
                local isSequential = true
                for k in pairs(arg) do
                    if type(k) ~= "number" or k < 1 or math.floor(k) ~= k then
                        isSequential = false
                        break
                    end
                end

                if isSequential then
                    local tableParts = {}
                    for _, v in ipairs(arg) do
                        tableParts[#tableParts + 1] = tostring(v)
                    end
                    messageParts[#messageParts + 1] = table.concat(tableParts, ", ")
                else
                    local tableParts = {}
                    for k, v in pairs(arg) do
                        tableParts[#tableParts + 1] = tostring(k) .. "=" .. tostring(v)
                    end
                    messageParts[#messageParts + 1] = "{" .. table.concat(tableParts, ", ") .. "}"
                end
            else
                messageParts[#messageParts + 1] = tostring(arg)
            end
        end

        local message = table.concat(messageParts, " ")
        local modName = HelmetOffDialog.MOD_NAME
        System.LogAlways(string.format("%s[%s] [%s.%s] %s",
                colorCode, localTime, modName, level, message))
    end,
    info = function(...)
        if not HelmetOffDialog:config():isProduction() then
            HelmetOffDialog.Log._log("INFO", "$5", ...)
        end
    end,
    error = function(...)
        HelmetOffDialog.Log._log("ERROR", "$4", ...)
    end
}

HelmetOffDialog.Log = Log

return Log