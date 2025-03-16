HelmetOffDialog_Ranged = {}

function HelmetOffDialog_Ranged:loadSettings(actionName, eventName, argTable)
    System.ExecuteCommand("helmet_off_dialog__set_ranged = true")
end

UIAction.RegisterEventSystemListener(
        HelmetOffDialog_Ranged, "System", "OnGameplayStart", "loadSettings"
)

