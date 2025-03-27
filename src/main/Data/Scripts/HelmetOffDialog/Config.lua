--- @class Config
--- @field isProduction fun(self: Config): boolean
--- @field environment string
--- @field isRanged fun(self: Config): boolean
--- @field setRanged fun(self: Config, value: boolean)
--- @field isRandom fun(self: Config): boolean
--- @field setRandom fun(self: Config, value: boolean)
--- @field isHelmetOnly fun(self: Config): boolean
--- @field setHelmetOnly fun(self: Config, value: boolean)
local Config = {
    environment = nil,
    new = function(self, environment)
        if _G.HelmetOffDialog.__factories.config then
            return _G.HelmetOffDialog.__factories.config
        end
        local instance = {
            environment = environment,
            ranged = false,
            helmet_only = false,
            random = false
        }

        setmetatable(instance, { __index = self })
        _G.HelmetOffDialog.__factories.config = instance

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
        self.ranged = self:sanitize(value)
    end,
    isRandom = function(self)
        return self.random
    end,
    setRandom = function(self, value)
        self.random = self:sanitize(value)
    end,
    isHelmetOnly = function(self)
        return self.helmet_only
    end,
    setHelmetOnly = function(self, value)
        self.helmet_only = self:sanitize(value)
    end,
    sanitize = function(self, value)
        local sanitized = (tostring(value):match("^%s*=?%s*(.-)%s*$") or "")
        return sanitized:lower() == "true" or sanitized == "1"
    end
}

_G.HelmetOffDialog.ClassRegistry.Config = Config

return Config