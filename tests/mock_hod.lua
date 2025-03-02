local factory = {}

function factory.mockHelmetOffDialog(mock, spy)
    _G.Script = {
        SetTimer = function()
        end,
        LoadScript = function()
        end
    }
    _G.System = {
        LogAlways = function()
        end
    }
    _G.BasicAIActions = {
        OnTalk = function()
        end
    }

    dofile("src/Data/Scripts/helmet_off_dialog/helmet_off_dialog.lua")
    dofile("src/Data/Scripts/helmet_off_dialog/utils/error.lua")
    dofile("src/Data/Scripts/helmet_off_dialog/on_talk_event.lua")
    dofile("src/Data/Scripts/helmet_off_dialog/config.lua")
    dofile("src/Data/Scripts/helmet_off_dialog/utils/log.lua")
    dofile("src/Data/Scripts/helmet_off_dialog/utils/timed_trigger.lua")
    dofile("src/Data/Scripts/helmet_off_dialog/equipped_item.lua")
    dofile("src/Data/Scripts/helmet_off_dialog/equipment.lua")

    local Error = mock(HelmetOffDialog.ClassRegistry.Error)
    local Log = mock(HelmetOffDialog.ClassRegistry.Log, true)
    local OnTalkEvent = mock(HelmetOffDialog.ClassRegistry.OnTalkEvent, true)
    local HelmetOffDialog = mock(HelmetOffDialog, true)
    HelmetOffDialog.log = function()
        return Log
    end
    HelmetOffDialog.error = function()
        return Error
    end
    HelmetOffDialog.onTalkEvent = function()
        return OnTalkEvent
    end
    spy.on(HelmetOffDialog, "onTalkEvent")
    spy.on(HelmetOffDialog, "error")

    return { HelmetOffDialog = HelmetOffDialog }
end

return factory