local Log = HelmetOffDialog.Log

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
}

_G.HelmetOffDialog.ClassRegistry.Commands = Commands

return Commands
--local config = _G.HelmetOffDialog:config()
--local Log = _G.HelmetOffDialog.Log
--
--function _G.HelmetOffDialog:setHelmetOnly(input)
--    Log.info("setHelmetOnly called with argument: ", input)
--    config:setHelmetOnly(input)
--end
--
--_G.System.AddCCommand(
--        "helmet_off_dialog__set_helmet_only",
--        "HelmetOffDialog:setHelmetOnly(%line)",
--        ""
--);
--
--function _G.HelmetOffDialog:setRandom(rawInput)
--    Log.info("setRandom called with argument: ", rawInput)
--    config:setRandom(rawInput)
--end
--
--_G.System.AddCCommand(
--        "helmet_off_dialog__set_random",
--        "HelmetOffDialog:setRandom(%line)",
--        ""
--);
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
