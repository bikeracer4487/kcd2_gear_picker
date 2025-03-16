local log = _G.HelmetOffDialog:log()

function _G.HelmetOffDialog:OnLoadingComplete(actionName, eventName, argTable)
    log:info("Configuration:load")
    _G.System.ExecuteCommand("exec Mods/helmet_off_dialog/mod.cfg")
end
_G.UIAction.RegisterEventSystemListener(
        _G.HelmetOffDialog,
        "System",
        "OnLoadingComplete",
        "OnLoadingComplete"
)

function _G.HelmetOffDialog:setHideRangedWeapons(rawInput)
    log:info("setHideRangedWeapons called with argument: ", rawInput)

    local sanitized = (tostring(rawInput):match("^%s*=?%s*(.-)%s*$") or "")
    local setting = sanitized:lower() == "true" or sanitized == "1"

    log:info("Setting hide ranged weapon with value: ", setting)

    local config = _G.HelmetOffDialog:config()
    config:setHideRangedWeapons(setting)
end

_G.System.AddCCommand(
        "helmet_off_dialog__set_hide_ranged_weapons",
        "HelmetOffDialog:setHideRangedWeapons(%line)",
        ""
);
