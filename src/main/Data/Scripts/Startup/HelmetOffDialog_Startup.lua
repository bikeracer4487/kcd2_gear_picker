Script.LoadScript("Scripts/HelmetOffDialog/HelmetOffDialog.lua")

_G.HelmetOffDialog:init()

function HelmetOffDialog:OnGameplayStart(actionName, eventName, argTable)
    Script.LoadScript("Scripts/HelmetOffDialog/RegisterOnTalkEvents.lua")
end

UIAction.RegisterEventSystemListener(
        HelmetOffDialog, "System", "OnGameplayStart", "OnGameplayStart"
)
