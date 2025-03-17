HelmetOffDialogHelmetOnly_Startup = {}

function HelmetOffDialogHelmetOnly_Startup:OnGameplayStartKcdOne()
    System.ExecuteCommand("helmet_off_dialog__set_helmet_only = true")
end

UIAction.RegisterEventSystemListener(
        HelmetOffDialogHelmetOnly_Startup,
        "System",
        "OnGameplayStart",
        "OnGameplayStartKcdOne"
)

