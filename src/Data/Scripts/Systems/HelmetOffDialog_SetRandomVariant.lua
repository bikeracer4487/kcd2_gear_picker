local log = _G.HelmetOffDialog:log()
local config = _G.HelmetOffDialog:config()

function _G.HelmetOffDialog:setRandomVariant(rawInput)
    log:info("setRandomVariant called with argument: ", rawInput)
    config:setRandomVariant(rawInput)
end

_G.System.AddCCommand(
        "helmet_off_dialog__set_random_variant",
        "HelmetOffDialog:setRandomVariant(%line)",
        ""
);
