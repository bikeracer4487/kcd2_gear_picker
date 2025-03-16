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
