local Log = GearPicker.Log

--- @class Config
local Config = {
    new = function(self, environment)
        local instance = {
            environment = environment,
            is_mod_off = false,
            is_debug = false,
            
            -- Optimization priority weights (0-100)
            priority_armor = 100,     -- Weight for armor/protection optimization
            priority_stealth = 0,     -- Weight for stealth optimization  
            priority_charisma = 0,    -- Weight for charisma optimization
            
            -- Defense type weights (0-100)
            stab_defense_weight = 33, -- Weight for stab defense
            slash_defense_weight = 33, -- Weight for slash defense
            blunt_defense_weight = 33, -- Weight for blunt defense
            
            -- Stealth component weights (0-100)
            noise_weight = 40,        -- Weight for noise reduction
            visibility_weight = 30,   -- Weight for visibility reduction
            conspicuousness_weight = 30, -- Weight for conspicuousness reduction
            
            -- Weight limits
            max_weight_percentage = 80, -- Maximum % of weight capacity to use
            
            -- Feature flags
            auto_optimize = false     -- Automatically optimize on situation change
        }
        setmetatable(instance, { __index = self })
        return instance
    end,
    
    -- Environment
    isProduction = function(self)
        return self.environment == "prod"
    end,
    
    isDebug = function(self)
        return self.is_debug
    end,
    
    setDebug = function(self, value)
        self.is_debug = self:_parseSettingValue(value)
    end,
    
    isModOff = function(self)
        return self.is_mod_off
    end,
    
    setModOff = function(self, value)
        self.is_mod_off = self:_parseSettingValue(value)
    end,
    
    -- Optimization priorities
    setPriorityArmor = function(self, value)
        self.priority_armor = self:_parseNumericValue(value, 0, 100)
    end,
    
    setPriorityStealth = function(self, value)
        self.priority_stealth = self:_parseNumericValue(value, 0, 100)
    end,
    
    setPriorityCharisma = function(self, value)
        self.priority_charisma = self:_parseNumericValue(value, 0, 100)
    end,
    
    -- Defense type weights
    setStabDefenseWeight = function(self, value)
        self.stab_defense_weight = self:_parseNumericValue(value, 0, 100)
    end,
    
    setSlashDefenseWeight = function(self, value)
        self.slash_defense_weight = self:_parseNumericValue(value, 0, 100)
    end,
    
    setBluntDefenseWeight = function(self, value)
        self.blunt_defense_weight = self:_parseNumericValue(value, 0, 100)
    end,
    
    -- Stealth component weights
    setNoiseWeight = function(self, value)
        self.noise_weight = self:_parseNumericValue(value, 0, 100)
    end,
    
    setVisibilityWeight = function(self, value)
        self.visibility_weight = self:_parseNumericValue(value, 0, 100)
    end,
    
    setConspicuousnessWeight = function(self, value)
        self.conspicuousness_weight = self:_parseNumericValue(value, 0, 100)
    end,
    
    -- Weight limits
    setMaxWeightPercentage = function(self, value)
        self.max_weight_percentage = self:_parseNumericValue(value, 0, 100)
    end,
    
    -- Feature flags
    setAutoOptimize = function(self, value)
        self.auto_optimize = self:_parseSettingValue(value)
    end,
    
    -- Helper functions
    _parseSettingValue = function(self, arg)
        local value = (tostring(arg):match("^%s*=?%s*(.-)%s*$") or "")
        return value:lower() == "true" or value == "1"
    end,
    
    _parseNumericValue = function(self, arg, min, max)
        local value = tonumber(arg) or 0
        return math.max(min, math.min(max, value))
    end
}

_G.GearPicker.ClassRegistry.Config = Config

return Config