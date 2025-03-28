function HelmetOffDialog:OnLoadingCompleteKcdTwo()
    HelmetOffDialog:init()
    HelmetOffDialog.KCD2 = true
    Script.LoadScript("Scripts/HelmetOffDialog/RegisterOnTalkEvents.lua")
    Script.LoadScript("Scripts/HelmetOffDialog/RegisterTradeMenuEvents.lua")
end

UIAction.RegisterEventSystemListener(
        HelmetOffDialog, "System", "OnLoadingComplete", "OnLoadingCompleteKcdTwo"
)
