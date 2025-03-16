System.LogAlways("HelmetOffDialog_Random")
HelmetOffDialog_Random = {}

function HelmetOffDialog_Random:loadSettings(actionName, eventName, argTable)
    System.LogAlways("HelmetOffDialog_Random:loadSettings")
    System.ExecuteCommand("helmet_off_dialog__set_random = true")
end

UIAction.RegisterEventSystemListener(
        HelmetOffDialog_Random, "System", "OnGameplayStart", "loadSettings"
)

