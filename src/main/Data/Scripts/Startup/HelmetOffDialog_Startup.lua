Script.LoadScript("Scripts/HelmetOffDialog/HelmetOffDialog.lua")
HelmetOffDialog:init()

function HelmetOffDialog:OnGameplayStartKcdOne(...)
    HelmetOffDialog.KCD1 = true
    Script.LoadScript("Scripts/HelmetOffDialog/RegisterOnTalkEvents.lua")
    Script.LoadScript("Scripts/HelmetOffDialog/RegisterTradeMenuEvents.lua")
end

UIAction.RegisterEventSystemListener(
        HelmetOffDialog,
        "System",
        "OnGameplayStart",
        "OnGameplayStartKcdOne"
)
