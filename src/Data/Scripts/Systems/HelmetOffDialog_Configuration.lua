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