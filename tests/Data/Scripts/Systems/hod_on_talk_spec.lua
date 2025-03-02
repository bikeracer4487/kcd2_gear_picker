dofile("tests/mock_hod.lua")

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
    local factory = dofile("tests/mock_hod.lua")
    local mock = factory.mockHelmetOffDialog(mock, spy)
    dofile("src/Data/Scripts/Systems/hod_on_talk.lua")

    return { BasicAIActions = _G.BasicAIActions, HelmetOffDialog = mock.HelmetOffDialog }
end
