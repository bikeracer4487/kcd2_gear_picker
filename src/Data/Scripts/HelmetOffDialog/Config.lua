--- @class Config
--- @field isProduction fun(self: Config): boolean
--- @field environment string
--- @field new Config

local Config = {
    environment = nil,
    new = function(self, environment)
        if HelmetOffDialog.__factories.config then
            return HelmetOffDialog.__factories.config
        end
        local instance = { environment = environment, }
        setmetatable(instance, { __index = self })
        HelmetOffDialog.__factories.config = instance

        return instance
    end,
    isProduction = function(self)
        --- @type Config
        local config = self
        return config.environment == "prod"
    end
}

HelmetOffDialog.ClassRegistry.Config = Config

return Config