local function mockHelmetOffDialog(mock, spy)
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
        OnTalk = function(self)
            return "lorem-ipsum"
        end
    }
    local mockedBasicAIActions = mock(_G.BasicAIActions, true)

    dofile("src/Data/Scripts/HelmetOffDialog/HelmetOffDialog.lua")
    dofile("src/Data/Scripts/HelmetOffDialog/utils/Error.lua")
    dofile("src/Data/Scripts/HelmetOffDialog/OnTalkEvent.lua")
    dofile("src/Data/Scripts/HelmetOffDialog/Config.lua")
    dofile("src/Data/Scripts/HelmetOffDialog/utils/Log.lua")
    dofile("src/Data/Scripts/HelmetOffDialog/utils/TimedTrigger.lua")
    dofile("src/Data/Scripts/HelmetOffDialog/EquippedItem.lua")
    dofile("src/Data/Scripts/HelmetOffDialog/Equipment.lua")

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

    return {
        HelmetOffDialog = HelmetOffDialog,
        mockedBasicAIActions = mockedBasicAIActions
    }
end

return mockHelmetOffDialog