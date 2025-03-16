local log = _G.HelmetOffDialog:log()
local config = _G.HelmetOffDialog:config()

function _G.HelmetOffDialog:setHelmetOnly(input)
    log:info("setHelmetOnly called with argument: ", input)
    config:setHelmetOnly(input)
end

_G.System.AddCCommand(
        "helmet_off_dialog__set_helmet_only",
        "HelmetOffDialog:setHelmetOnly(%line)",
        ""
);


function _G.HelmetOffDialog:setRandom(rawInput)
    log:info("setRandom called with argument: ", rawInput)
    config:setRandom(rawInput)
end

_G.System.AddCCommand(
        "helmet_off_dialog__set_random",
        "HelmetOffDialog:setRandom(%line)",
        ""
);

function _G.HelmetOffDialog:setRanged(rawInput)
    log:info("setRanged called with argument: ", rawInput)
    config:setRanged(rawInput)
end

_G.System.AddCCommand(
        "helmet_off_dialog__set_ranged",
        "HelmetOffDialog:setRanged(%line)",
        ""
);
