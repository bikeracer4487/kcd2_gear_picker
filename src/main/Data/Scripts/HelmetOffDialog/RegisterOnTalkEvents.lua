local log = HelmetOffDialog:log()

local original_Entity_GetPos = Entity.GetPos

function Entity.GetPos(...)
    local log = HelmetOffDialog:log()
    log:info("OnTalkEvent: Triggered by Entity.GetPos")

    --- @type _G.Entity
    local this = ...

    HelmetOffDialog:error():catch(function()
        --- @type OnTalkEvent
        local event = HelmetOffDialog:onTalkEvent()
        event:handle(this)
    end)

    return original_Entity_GetPos(...)
end

function HelmetOffDialog:ApseCharacterOnInit(elementName, instanceId, eventName, argTable)
    log:info("ApseCharacterOnInit", elementName, instanceId, eventName, argTable)

    if eventName ~= "OnInit" then
        return
    end

    --- @type TalkEndedEvent
    local event = HelmetOffDialog:talkEndedEvent()
    event:forcePutOn()
end
UIAction.RegisterElementListener(Debugger, "ApseCharacter", -1, "", "ApseCharacterOnInit")
