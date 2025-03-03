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

describe("player can still start dialogues", function()
    test("original OnTalk function is called", function()
        local factory = makeFactory()
        factory.BasicAIActions:OnTalk()
        assert.spy(factory.original_BasicAIActions_onTalk).was.called(1)
    end)
    test("original OnTalk returns output", function()
        local factory = makeFactory()
        factory.BasicAIActions:OnTalk()
        assert.spy(factory.original_BasicAIActions_onTalk).was.called(1)
    end)
end)

function makeFactory()
    local factory = dofile("tests/mock_hod.lua")
    local mock = factory.mockHelmetOffDialog(mock, spy)
    local original_BasicAIActions_onTalk = mock.mockedBasicAIActions.OnTalk
    dofile("src/Data/Scripts/Systems/hod_on_talk.lua")

    return {
        BasicAIActions = _G.BasicAIActions,
        HelmetOffDialog = mock.HelmetOffDialog,
        original_BasicAIActions_onTalk = original_BasicAIActions_onTalk
    }
end
