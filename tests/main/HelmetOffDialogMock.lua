local function mockHelmetOffDialog(mock, spy)
    _G.HelmetOffDialog = nil

    _G.UIAction = { RegisterEventSystemListener = function()
    end }
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
    _G.Entity = {
        GetPos = function(self)
            return "lorem-ipsum"
        end
    }
    local mockedEntity = mock(_G.Entity, true)

    dofile("src/main/Data/Scripts/HelmetOffDialog/HelmetOffDialog.lua")
    dofile("src/main/Data/Scripts/HelmetOffDialog/utils/Error.lua")
    dofile("src/main/Data/Scripts/HelmetOffDialog/OnTalkEvent.lua")
    dofile("src/main/Data/Scripts/HelmetOffDialog/Config.lua")
    dofile("src/main/Data/Scripts/HelmetOffDialog/utils/Log.lua")
    dofile("src/main/Data/Scripts/HelmetOffDialog/utils/TimedTrigger.lua")
    dofile("src/main/Data/Scripts/HelmetOffDialog/EquippedItem.lua")
    dofile("src/main/Data/Scripts/HelmetOffDialog/Equipment.lua")

    local Error = mock(HelmetOffDialog.ClassRegistry.Error)
    local Log = mock(HelmetOffDialog.ClassRegistry.Log, true)
    local OnTalkEvent = mock(HelmetOffDialog.ClassRegistry.OnTalkEvent, true)
    local Config = mock(HelmetOffDialog.ClassRegistry.Config, true)
    local HelmetOffDialog = mock(HelmetOffDialog, true)
    HelmetOffDialog.log = function()
        return Log
    end
    HelmetOffDialog.error = function()
        return Error
    end
    HelmetOffDialog.config = function()
        return Config
    end
    HelmetOffDialog.onTalkEvent = function()
        return OnTalkEvent
    end
    spy.on(HelmetOffDialog, "onTalkEvent")
    spy.on(HelmetOffDialog, "error")

    return {
        HelmetOffDialog = HelmetOffDialog,
        mockedEntity = mockedEntity
    }
end

return mockHelmetOffDialog