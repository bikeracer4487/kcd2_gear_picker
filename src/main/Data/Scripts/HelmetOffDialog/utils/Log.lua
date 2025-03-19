--- @class Log
--- @field info fun(self: Log, ...: any)
--- @field error fun(self: Log, msg: string)
--- @field modName string
--- @field config table
--- @field new fun(self: Log, modName: string, config: Config)

local Log = {
    modName = nil,
    config = nil,
    new = function(self, modName, config)
        if HelmetOffDialog.__factories.log then
            return HelmetOffDialog.__factories.log
        end
        local instance = { modName = modName, config = config }
        setmetatable(instance, { __index = self })
        HelmetOffDialog.__factories.log = instance
        return instance
    end,
    getLocalTime = function(self)
        local localTime = System.GetLocalOSTime()
        return string.format("%04d-%02d-%02d %02d:%02d:%02d",
                localTime.year + 1900, localTime.mon + 1, localTime.mday,
                localTime.hour, localTime.min, localTime.sec)
    end,
    _log = function(self, level, colorCode, ...)
        local localTime = self:getLocalTime()
        local args = {...}
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
        System.LogAlways(string.format("%s[%s] [%s.%s] %s",
                colorCode, localTime, self.modName, level, message))
    end,
    info = function(self, ...)
        local config = self.config
        if not config:isProduction() then
            self:_log("INFO", "$5", ...)
        end
    end,
    error = function(self, ...)
        self:_log("ERROR", "$4", ...)
    end
}

HelmetOffDialog.ClassRegistry.Log = Log

return Log