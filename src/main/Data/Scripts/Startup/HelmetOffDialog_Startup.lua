Script.LoadScript("Scripts/HelmetOffDialog/HelmetOffDialog.lua")

_G.HelmetOffDialog:init()

function HelmetOffDialog:OnGameplayStartKcdOne()
    Script.LoadScript("Scripts/HelmetOffDialog/RegisterOnTalkEvents.lua")
    Script.LoadScript("Scripts/HelmetOffDialog/RegisterTradeMenuEvents.lua")
end

UIAction.RegisterEventSystemListener(
        HelmetOffDialog, "System", "OnGameplayStart", "OnGameplayStartKcdOne"
)
