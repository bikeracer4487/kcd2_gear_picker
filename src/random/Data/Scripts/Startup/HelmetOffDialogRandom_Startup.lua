HelmetOffDialogRandom_Startup = {}

function HelmetOffDialogRandom_Startup:OnGameplayStartKcdOne()
    System.ExecuteCommand("helmet_off_dialog__set_random = true")
end

UIAction.RegisterEventSystemListener(
        HelmetOffDialogRandom_Startup,
        "System",
        "OnGameplayStart",
        "OnGameplayStartKcdOne"
)

