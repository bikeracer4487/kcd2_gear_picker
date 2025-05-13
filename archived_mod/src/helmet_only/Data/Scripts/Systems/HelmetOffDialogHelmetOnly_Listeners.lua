HelmetOffDialogHelmetOnly_Listeners = {}

function HelmetOffDialogHelmetOnly_Listeners:OnLoadingCompleteKcdTwo()
    System.ExecuteCommand("helmet_off_dialog__set_helmet_only = true")
end

UIAction.RegisterEventSystemListener(
        HelmetOffDialogHelmetOnly_Listeners,
        "System",
        "OnLoadingComplete",
        "OnLoadingCompleteKcdTwo"
)
