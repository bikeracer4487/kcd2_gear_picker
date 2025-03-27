function HelmetOffDialog:ApseCharacterOnInit(
        elementName, instanceId, eventName, argTable
)
    local log = HelmetOffDialog:log()
    log:info("ApseCharacterOnInit", elementName, instanceId, eventName, argTable)

    if eventName ~= "OnInit" then
        return
    end

    --- @type TalkEndedEvent
    local event = HelmetOffDialog:talkEndedEvent()
    event:forcePutOn()
end

UIAction.RegisterElementListener(
        HelmetOffDialog, "ApseCharacter", -1, "", "ApseCharacterOnInit"
)