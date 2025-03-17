HelmetOffDialogRanged_Startup = {}

function HelmetOffDialogRanged_Startup:OnGameplayStartKcdOne()
    System.ExecuteCommand("helmet_off_dialog__set_ranged = true")
end

UIAction.RegisterEventSystemListener(
        HelmetOffDialogRanged_Startup,
        "System",
        "OnGameplayStart",
        "OnGameplayStartKcdOne"
)

