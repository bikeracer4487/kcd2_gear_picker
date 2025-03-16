--- @class Config
--- @field isProduction fun(self: Config): boolean
--- @field environment string
--- @field new Config
--- @field isRanged fun(self: Config): boolean
--- @field setRanged fun(self: Config): boolean
--- @field setRandom fun(self: Config): boolean
--- @field isRandom fun(self: Config): boolean
--- @field setHelmetOnly fun(self: Config): boolean
--- @field isHelmetOnly fun(self: Config): boolean

local Config = {
    environment = nil,
    new = function(self, environment)
        if _G.HelmetOffDialog.__factories.config then
            return _G.HelmetOffDialog.__factories.config
        end
        local instance = { environment = environment, }
        setmetatable(instance, {
            __index = self,
            ranged_variant = false,
            helmet_only_variant = false,
            random_variant = false
        })
        _G.HelmetOffDialog.__factories.config = instance

        return instance
    end,
    isProduction = function(self)
        --- @type Config
        local config = self
        return config.environment == "prod"
    end,
    isRanged = function(self)
        return self.ranged_variant
    end,
    setRanged = function(self, value)
        self.ranged_variant = self:sanitize(value)
    end,
    isRandom = function(self)
        return self.random_variant
    end,
    setRandom = function(self, value)
        self.random_variant = self:sanitize(value)
    end,
    isHelmetOnly = function(self)
        return self.helmet_only_variant
    end,
    setHelmetOnly = function(self, value)
        self.helmet_only_variant = self:sanitize(value)
    end,
    sanitize = function(self, value)
        local sanitized = (tostring(value):match("^%s*=?%s*(.-)%s*$") or "")
        return sanitized:lower() == "true" or sanitized == "1"
    end
}

_G.HelmetOffDialog.ClassRegistry.Config = Config

return Config