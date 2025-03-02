dofile("tests/mock_helmet_off_dialog_spec.lua")

describe("triggers the on talk event", function()
    it("creates the event", function()
        local factory = makeFactory()
        factory.BasicAIActions:OnTalk()
        assert.spy(factory.HelmetOffDialog.onTalkEvent).was.called(1)
    end)
    it("triggers the event", function()
        local factory = makeFactory()
        factory.BasicAIActions:OnTalk()
        assert.spy(factory.HelmetOffDialog.onTalkEvent().handle).was.called(1)
    end)
end)

function makeFactory()
    --mockHelmetOffDialog()

    _G.Log = { info = function()
    end, error = function()
    end }
    _G.Error = { catch = function(callback)
        callback()
    end }

    _G.Script = {
        SetTimer = function()
        end,
        LoadScript = function()
        end
    }
    _G.System = { LogAlways = function()
    end }
    _G.Config = { LogAlways = function()
    end }
    _G.player = { Lorem = function()
    end }

    dofile("src/Data/Scripts/helmet_off_dialog/helmet_off_dialog.lua")
    dofile("src/Data/Scripts/helmet_off_dialog/on_talk_event.lua")
    dofile("src/Data/Scripts/helmet_off_dialog/config.lua")
    dofile("src/Data/Scripts/helmet_off_dialog/utils/log.lua")
    dofile("src/Data/Scripts/helmet_off_dialog/utils/timed_trigger.lua")
    dofile("src/Data/Scripts/helmet_off_dialog/equipped_item.lua")
    dofile("src/Data/Scripts/helmet_off_dialog/equipment.lua")
    local OnTalkEvent = mock(HelmetOffDialog.ClassRegistry.OnTalkEvent, true)
    local HelmetOffDialog = mock(HelmetOffDialog, true)
    HelmetOffDialog.onTalkEvent = function()
        return OnTalkEvent
    end
    spy.on(HelmetOffDialog, "onTalkEvent")
    --HelmetOffDialog.onTalkEvent = stub(OnTalkEvent)

    _G.BasicAIActions = {
        OnTalk = function()
        end
    }
    dofile("src/Data/Scripts/Systems/helmet_off_dialog_on_talk.lua")

    return { BasicAIActions = BasicAIActions, HelmetOffDialog = HelmetOffDialog }
end