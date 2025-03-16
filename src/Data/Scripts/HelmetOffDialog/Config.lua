--- @class Config
--- @field isProduction fun(self: Config): boolean
--- @field environment string
--- @field new Config
--- @field isRangedVariant fun(self: Config): boolean
--- @field setRangedVariant fun(self: Config): boolean
--- @field setRandomVariant fun(self: Config): boolean
--- @field isRandomVariant fun(self: Config): boolean
--- @field setHelmetOnlyVariant fun(self: Config): boolean
--- @field isHelmetOnlyVariant fun(self: Config): boolean

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
    isRangedVariant = function(self)
        return self.ranged_variant
    end,
    setRangedVariant = function(self, value)
        self.ranged_variant = self:sanitize(value)
    end,
    isRandomVariant = function(self)
        return self.random_variant
    end,
    setRandomVariant = function(self, value)
        self.random_variant = self:sanitize(value)
    end,
    isHelmetOnlyVariant = function(self)
        return self.helmet_only_variant
    end,
    setHelmetOnlyVariant = function(self, value)
        self.helmet_only_variant = self:sanitize(value)
    end,
    sanitize = function(self, value)
        local sanitized = (tostring(value):match("^%s*=?%s*(.-)%s*$") or "")
        return sanitized:lower() == "true" or sanitized == "1"
    end
}

_G.HelmetOffDialog.ClassRegistry.Config = Config

return Config