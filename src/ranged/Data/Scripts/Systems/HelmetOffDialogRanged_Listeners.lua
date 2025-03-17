HelmetOffDialogRanged_Listeners = {}

function HelmetOffDialogRanged_Listeners:OnLoadingCompleteKcdTwo()
    System.ExecuteCommand("helmet_off_dialog__set_ranged = true")
end

UIAction.RegisterEventSystemListener(
        HelmetOffDialogRanged_Listeners,
        "System",
        "OnLoadingComplete",
        "OnLoadingCompleteKcdTwo"
)
