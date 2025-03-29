local Log = _G.HelmetOffDialog.Log

--- @class Commands
--- @field new fun(self: Commands, system: _G.System): Commands
--- @field system _G.System
--- @field config Config
local Commands = {
    new = function(self, system, config, helmetOffDialog)
        local instance = {
            system = system, config = config, helmetOffDialog = helmetOffDialog
        }
        setmetatable(instance, { __index = self })
        Log.info("Commands New instance created")
        return instance
    end,
    handle = function(self)
        --- @type Commands
        local this = self

        this.system.AddCCommand(
                "helmet_off_dialog__set_random",
                "HelmetOffDialog:setRandom(%line)"
        )
        this.helmetOffDialog.setRandom = function(self, input)
            Log.info("setRandom called with argument: ", input)
            this.config:setRandom(input)
        end

        this.system.AddCCommand(
                "helmet_off_dialog__set_helmet_only",
                "HelmetOffDialog:setHelmetOnly(%line)"
        )
        this.helmetOffDialog.setHelmetOnly = function(self, input)
            Log.info("setHelmetOnly called with argument: ", input)
            this.config:setHelmetOnly(input)
        end

        this.system.AddCCommand(
                "helmet_off_dialog__set_turn_off",
                "HelmetOffDialog:setTurnOff(%line)"
        )
        this.helmetOffDialog.setTurnOff = function(self, input)
            Log.info("setTurnOff called with argument: ", input)
            this.config:setTurnOff(input)
        end
    end
}

_G.HelmetOffDialog.ClassRegistry.Commands = Commands

return Commands
--
--function _G.HelmetOffDialog:setRandom(rawInput)
--    Log.info("setRandom called with argument: ", rawInput)
--    config:setRandom(rawInput)
--end
--
--function _G.HelmetOffDialog:setRanged(rawInput)
--    Log.info("setRanged called with argument: ", rawInput)
--    config:setRanged(rawInput)
--end
--
--_G.System.AddCCommand(
--        "helmet_off_dialog__set_ranged",
--        "HelmetOffDialog:setRanged(%line)",
--        ""
--);
----
--function _G.HelmetOffDialog:setTurnOff(self, input)
--    Log.info("setTurnOff called with argument: ", input)
--    config:setTurnOff(input)
--end
--
--_G.System.AddCCommand(
--        "helmet_off_dialog__set_turn_off",
--        "HelmetOffDialog:setTurnOff(%line)"
--);
