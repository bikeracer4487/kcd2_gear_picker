local Log = _G.HelmetOffDialog.Log

--- @class Commands
--- @field new fun(self: Commands, system: _G.System): Commands
--- @field system _G.System
--- @field config Config
local Commands = {
    new = function(self, system, config)
        local instance = { system = system, config = config }
        setmetatable(instance, { __index = self })
        Log.info("Commands New instance created")
        return instance
    end,
    init = function(self)
        --- @type Commands
        local this = self

        this.system.AddCCommand("helmet_off_dialog__set_ranged", "HelmetOffDialog:commands():setRanged(%line)", "")
        this.system.AddCCommand("helmet_off_dialog__set_random", "HelmetOffDialog:commands():setRandom(%line)", "")
        this.system.AddCCommand(
                "helmet_off_dialog__set_helmet_only", "HelmetOffDialog:commands():setHelmetOnly(%line)", ""
        )
        this.system.AddCCommand("helmet_off_dialog__set_turn_off", "HelmetOffDialog:commands():setTurnOff(%line)", "")
        
        this.system.AddCCommand("helmet_off_dialog__set_turn_off", "HelmetOffDialog:commands():setTurnOff(%line)", "")
    end,

    setRanged = function(self, input)
        Log.info("setRanged called with argument: ", input)
        self.config:setRanged(input)
    end,
    setRandom = function(self, input)
        Log.info("setRandom called with argument: ", input)
        self.config:setRandom(input)
    end,
    setHelmetOnly = function(self, input)
        Log.info("setHelmetOnly called with argument: ", input)
        self.config:setHelmetOnly(input)
    end,
    setTurnOff = function(self, input)
        Log.info("setTurnOff called with argument: ", input)
        self.config:setTurnOff(input)
    end
}

_G.HelmetOffDialog.ClassRegistry.Commands = Commands

return Commands