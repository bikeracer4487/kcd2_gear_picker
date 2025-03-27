dofile("tests/main/HelmetOffDialogMock.lua")

describe("triggers the on talk event", function()
    it("creates the event", function()
        local factory = makeFactory()
        factory.Entity.GetPos()
        assert.spy(factory.HelmetOffDialog.onTalkEvent).was.called(1)
    end)
    it("triggers the event", function()
        local factory = makeFactory()
        factory.Entity.GetPos()
        assert.spy(factory.HelmetOffDialog.onTalkEvent().handle).was.called(1)
    end)
end)

describe("player can still start dialogues: ", function()
    test("original OnTalk function is called", function()
        local factory = makeFactory()
        factory.Entity.GetPos()
        assert.spy(factory.original_Entity_GetPos).was.called(1)
    end)
    test("original OnTalk returns output", function()
        local factory = makeFactory()
        factory.Entity.GetPos()
        assert.spy(factory.original_Entity_GetPos).was.called(1)
    end)
end)

function makeFactory()
    local mockHelmetOffDialog = dofile("tests/main/HelmetOffDialogMock.lua")
    local factory = mockHelmetOffDialog(mock, spy)

    local original_Entity_GetPos = factory.mockedEntity.GetPos
    dofile("src/main/Data/Scripts/HelmetOffDialog/RegisterOnTalkEvents.lua")

    return {
        Entity = _G.Entity,
        HelmetOffDialog = factory.HelmetOffDialog,
        original_Entity_GetPos = original_Entity_GetPos
    }
end

