local original_Entity_GetPos = Entity.GetPos
local Log = HelmetOffDialog.Log

function Entity.GetPos(...)
    Log.info("OnTalkEvent: Triggered by Entity.GetPos")

    --- @type _G.Entity
    local this = ...

    HelmetOffDialog:error():catch(function()
        --- @type OnTalkEvent
        local event = HelmetOffDialog:onTalkEvent()
        event:handle(this, _G.player)
    end)

    return original_Entity_GetPos(...)
end