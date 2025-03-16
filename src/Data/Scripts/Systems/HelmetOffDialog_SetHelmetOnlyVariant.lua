local log = _G.HelmetOffDialog:log()
local config = _G.HelmetOffDialog:config()

function _G.HelmetOffDialog:setHelmetOnlyVariant(input)
    log:info("setHelmetOnlyVariant called with argument: ", input)
    config:setHelmetOnlyVariant(input)
end

_G.System.AddCCommand(
        "helmet_off_dialog__set_helmet_only_variant",
        "HelmetOffDialog:setHelmetOnlyVariant(%line)",
        ""
);
