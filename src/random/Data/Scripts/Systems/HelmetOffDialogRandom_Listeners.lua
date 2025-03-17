HelmetOffDialogRandom_Listeners = {}

function HelmetOffDialogRandom_Listeners:OnLoadingCompleteKcdTwo()
    System.ExecuteCommand("helmet_off_dialog__set_random = true")
end

UIAction.RegisterEventSystemListener(
        HelmetOffDialogRandom_Listeners,
        "System",
        "OnLoadingComplete",
        "OnLoadingCompleteKcdTwo"
)
