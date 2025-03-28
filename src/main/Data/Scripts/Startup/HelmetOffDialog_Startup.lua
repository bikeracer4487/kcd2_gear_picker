Script.LoadScript("Scripts/HelmetOffDialog/HelmetOffDialog.lua")

function HelmetOffDialog:OnGameplayStartKcdOne()
    _G.HelmetOffDialog:init()
    Script.LoadScript("Scripts/HelmetOffDialog/RegisterOnTalkEvents.lua")
    Script.LoadScript("Scripts/HelmetOffDialog/RegisterTradeMenuEvents.lua")
end

UIAction.RegisterEventSystemListener(
        HelmetOffDialog, "System", "OnGameplayStart", "OnGameplayStartKcdOne"
)
