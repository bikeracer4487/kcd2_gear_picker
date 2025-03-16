local log = _G.HelmetOffDialog:log()
local config = _G.HelmetOffDialog:config()

function _G.HelmetOffDialog:setRanged(rawInput)
    log:info("setRanged called with argument: ", rawInput)
    config:setRanged(rawInput)
end

_G.System.AddCCommand(
        "helmet_off_dialog__set_ranged",
        "HelmetOffDialog:setRanged(%line)",
        ""
);
