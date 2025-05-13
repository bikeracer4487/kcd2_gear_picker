local Log = HelmetOffDialog.Log

function HelmetOffDialog:OnTradeMenuOpen(element, instanceId, event, args)
    Log.info("HelmetOffDialog:OnTradeMenuOpen", element, instanceId, event, args)

    ------- @type TalkEndedEvent
    local talkEndedEvent = HelmetOffDialog:talkEndedEvent()
    talkEndedEvent:forcePutOn()
end

local element = 'ApseCharacter'

if HelmetOffDialog.KCD1 then
    element = 'inventory'
end

UIAction.RegisterElementListener(
        HelmetOffDialog, element, -1, "OnShow", "OnTradeMenuOpen"
)