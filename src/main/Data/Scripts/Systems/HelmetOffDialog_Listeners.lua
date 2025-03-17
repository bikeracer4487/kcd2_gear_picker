function HelmetOffDialog:OnLoadingCompleteKcdTwo()
    Script.LoadScript("Scripts/HelmetOffDialog/RegisterOnTalkEvents.lua")
end

UIAction.RegisterEventSystemListener(
        HelmetOffDialog, "System", "OnLoadingComplete", "OnLoadingCompleteKcdTwo"
)
