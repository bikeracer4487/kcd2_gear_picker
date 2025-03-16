local original_Entity_GetPos = Entity.GetPos

function Entity.GetPos(...)
    local log = HelmetOffDialog:log()
    log:info("Entity.GetPos")
    local error = HelmetOffDialog:error()

    error:catch(function()
        local event = HelmetOffDialog:onTalkEvent()
        event:handle()
    end)

    return original_Entity_GetPos(...)
end
