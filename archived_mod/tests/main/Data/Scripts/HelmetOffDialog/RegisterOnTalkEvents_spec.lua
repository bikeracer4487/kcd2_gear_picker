describe("RegisterOnTalkEvents:", function()
    describe("triggers the on talk event:", function()
        it("creates the event", function()
            local factory = makeFactory()
            factory.entity.GetPos()
            assert.spy(factory.helmetOffDialog.onTalkEvent).was.called(1)
        end)
        it("triggers the event", function()
            local factory = makeFactory()
            factory.entity.GetPos()
            assert.spy(factory.helmetOffDialog.onTalkEvent().handle).was.called(1)
        end)
    end)

    describe("player can still start dialogues:", function()
        test("original OnTalk function is called", function()
            local factory = makeFactory()
            factory.entity.GetPos()
            assert.spy(factory.original_Entity_GetPos).was.called(1)
        end)
        test("original OnTalk returns output", function()
            local factory = makeFactory()
            factory.entity.GetPos()
            assert.spy(factory.original_Entity_GetPos).was.called(1)
        end)
    end)
end)

function makeFactory()
    local factory = {}
    factory.helmetOffDialog = dofile("tests/main/HelmetOffDialogMock.lua")(mock, spy)
    factory.entity = dofile("tests/main/EntityMock.lua")(mock, spy)

    factory.original_Entity_GetPos = factory.entity.GetPos
    dofile("src/main/Data/Scripts/HelmetOffDialog/RegisterOnTalkEvents.lua")

    return factory
end

