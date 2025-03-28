function HelmetOffDialog:OnLoadingCompleteKcdTwo()
    _G.HelmetOffDialog:init()
    Script.LoadScript("Scripts/HelmetOffDialog/RegisterOnTalkEvents.lua")
    Script.LoadScript("Scripts/HelmetOffDialog/RegisterTradeMenuEvents.lua")
end

UIAction.RegisterEventSystemListener(
        HelmetOffDialog, "System", "OnLoadingComplete", "OnLoadingCompleteKcdTwo"
)
