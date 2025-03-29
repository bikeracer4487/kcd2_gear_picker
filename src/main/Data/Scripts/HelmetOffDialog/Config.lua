--- @class Config
local Config = {
    new = function(self, environment)
        local instance = {
            environment = environment,
            ranged = false,
            helmet_only = false,
            random = false,
            turn_off = true
        }
        setmetatable(instance, { __index = self })
        return instance
    end,
    isProduction = function(self)
        return self.environment == "prod"
    end,
    isRanged = function(self)
        return self.ranged
    end,
    setRanged = function(self, value)
        self.ranged = self:_parseSettingValue(value)
    end,
    isRandom = function(self)
        return self.random
    end,
    setRandom = function(self, value)
        self.random = self:_parseSettingValue(value)
    end,
    isHelmetOnly = function(self)
        return self.helmet_only
    end,
    setHelmetOnly = function(self, value)
        self.helmet_only = self:_parseSettingValue(value)
    end,
    _parseSettingValue = function(self, arg)
        local value = (tostring(arg):match("^%s*=?%s*(.-)%s*$") or "")
        return value:lower() == "true" or value == "1"
    end,
    isTurnOff = function(self)
        return self.turn_off
    end,
    setTurnOff = function(self, value)
        self.turn_off = self:_parseSettingValue(value)
    end,
}

_G.HelmetOffDialog.ClassRegistry.Config = Config

return Config