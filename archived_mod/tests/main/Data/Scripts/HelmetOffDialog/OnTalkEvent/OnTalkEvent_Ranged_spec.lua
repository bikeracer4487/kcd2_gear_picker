describe("OnTalkEvent_Ranged:", function()
    it("takes off first ranged weapon", function()
        local factory = makeFactory({ features = "ranged" })
        factory.onTalkEvent:handle(factory.twinEntity, factory.player)
        assert.spy(factory.equipment.takeOffFirstRangedWeapon).was_called(1)
    end)

    it("does not take first ranged weapon off if not enabled", function()
        local factory = makeFactory()
        factory.onTalkEvent:handle(factory.twinEntity, factory.player)
        assert.spy(factory.equipment.takeOffFirstRangedWeapon).was_not_called()
    end)

    it("aborts if given entity offers shooting competition", function()
        local factory = makeFactory({ hasArcheryCompetition = true, features = "ranged" })
        factory.onTalkEvent:handle(factory.twinEntity, factory.player)
        assert.spy(factory.equipment.takeOffFirstRangedWeapon).was_not_called()
    end)

    it("queues take off for second ranged weapon", function()
        local factory = makeFactory({ features = "ranged" })
        factory.onTalkEvent:handle(factory.twinEntity, factory.player)
        assert.spy(factory.onTalkEvent.takeOffSecondRangedWeapon).was_called(1)
    end)

    it("takes off second ranged weapon", function()
        local factory = makeFactory({ features = "ranged" })
        factory.onTalkEvent:handle(factory.twinEntity, factory.player)
        assert.spy(factory.equipment.takeOffSecondRangedWeapon).was_called(1)
    end)

    it("does not take off second ranged weapon if not enabled", function()
        local factory = makeFactory()
        factory.onTalkEvent:handle(factory.twinEntity, factory.player)
        assert.spy(factory.equipment.takeOffSecondRangedWeapon).was_not_called()
    end)

    it("triggers talk ended event", function()
        local factory = makeFactory()
        factory.onTalkEvent:takeOffSecondRangedWeapon()
        assert.spy(factory.talkEndedEvent.listen).was_called(1)
    end)
end)

function makeFactory(args)
    local createFactory = dofile("tests/main/Data/Scripts/HelmetOffDialog/OnTalkEvent/OnTalkEvent_Factory.lua")
    return createFactory(mock, spy, args)
end

