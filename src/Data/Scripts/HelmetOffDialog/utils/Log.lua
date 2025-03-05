--- @class Log
--- @field info fun(self: Log, msg: string)
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
    info = function(self, message)
        local config = self.config
        if not config:isProduction() then
            local localTime = self:getLocalTime()
            System.LogAlways("$5[" .. localTime .. "] [" .. self.modName .. ".INFO] " .. message)
        end
    end,
    error = function(self, message)
        local localTime = self:getLocalTime()
        System.LogAlways("$4[" .. localTime .. "] [" .. self.modName .. ".ERROR] " .. message)
    end
}

HelmetOffDialog.ClassRegistry.Log = Log

return Log