--- @class Config
local Config = {
    --- @field environment string
    environment = nil,
    new = function(self, environment)
        local instance = {
            environment = environment,
            ranged = false,
            helmet_only = false,
            random = false
        }
        setmetatable(instance, { __index = self })
        return instance
    end,
    isProduction = function(self)
        --- @type Config
        local config = self
        return config.environment == "prod"
    end,
    isRanged = function(self)
        return self.ranged
    end,
    setRanged = function(self, value)
        self.ranged = self:parseSettingValue(value)
    end,
    isRandom = function(self)
        return self.random
    end,
    setRandom = function(self, value)
        self.random = self:parseSettingValue(value)
    end,
    isHelmetOnly = function(self)
        return self.helmet_only
    end,
    setHelmetOnly = function(self, value)
        self.helmet_only = self:parseSettingValue(value)
    end,
    parseSettingValue = function(self, arg)
        local value = (tostring(arg):match("^%s*=?%s*(.-)%s*$") or "")
        return value:lower() == "true" or value == "1"
    end
}

_G.HelmetOffDialog.ClassRegistry.Config = Config

return Config