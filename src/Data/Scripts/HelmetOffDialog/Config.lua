--- @class Config
--- @field isProduction fun(self: Config): boolean
--- @field environment string
--- @field new Config
--- @field isHideRangedWeapons fun(self: Config): boolean
--- @field setHideRangedWeapons fun(self: Config): boolean

local Config = {
    environment = nil,
    new = function(self, environment)
        if _G.HelmetOffDialog.__factories.config then
            return _G.HelmetOffDialog.__factories.config
        end
        local instance = { environment = environment, }
        setmetatable(instance, {
            __index = self,
            hide_ranged_weapons = false
        })
        _G.HelmetOffDialog.__factories.config = instance

        return instance
    end,
    isProduction = function(self)
        --- @type Config
        local config = self
        return config.environment == "prod"
    end,
    isHideRangedWeapons = function(self)
        return self.hide_ranged_weapons
    end,
    setHideRangedWeapons = function(self, value)
        self.hide_ranged_weapons = value
    end
}

_G.HelmetOffDialog.ClassRegistry.Config = Config

return Config