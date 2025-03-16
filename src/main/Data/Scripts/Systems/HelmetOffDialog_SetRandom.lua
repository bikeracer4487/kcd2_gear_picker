local log = _G.HelmetOffDialog:log()
local config = _G.HelmetOffDialog:config()

function _G.HelmetOffDialog:setRandom(rawInput)
    log:info("setRandom called with argument: ", rawInput)
    config:setRandom(rawInput)
end

_G.System.AddCCommand(
        "helmet_off_dialog__set_random",
        "HelmetOffDialog:setRandom(%line)",
        ""
);
