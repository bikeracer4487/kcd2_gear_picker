local log = _G.HelmetOffDialog:log()
local config = _G.HelmetOffDialog:config()

function _G.HelmetOffDialog:setRangedVariant(rawInput)
    log:info("setRangedVariant called with argument: ", rawInput)
    config:setRangedVariant(rawInput)
end

_G.System.AddCCommand(
        "helmet_off_dialog__set_ranged_variant",
        "HelmetOffDialog:setRangedVariant(%line)",
        ""
);
