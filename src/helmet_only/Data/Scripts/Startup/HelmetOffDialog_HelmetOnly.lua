System.LogAlways("HelmetOffDialog_HelmetOnly")
HelmetOffDialog_HelmetOnly = {}

function HelmetOffDialog_HelmetOnly:loadSettings(actionName, eventName, argTable)
    System.LogAlways("HelmetOffDialog_HelmetOnly:loadSettings")
    System.ExecuteCommand("helmet_off_dialog__set_helmet_only = true")
end

UIAction.RegisterEventSystemListener(
        HelmetOffDialog_HelmetOnly, "System", "OnGameplayStart", "loadSettings"
)

