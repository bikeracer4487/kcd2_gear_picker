it("takes off helmet", function()
    local factory = makeFactory({ features = "helmet_only" })
    factory.onTalkEvent:handle(factory.twinEntity)
    assert.spy(factory.equipment.takeOffHelmet).was_called(1)
end)

it("does not queue take off for head chainmail", function()
    local factory = makeFactory({ features = "helmet_only" })
    factory.onTalkEvent:handle(factory.twinEntity)
    assert.spy(factory.onTalkEvent.takeOffHeadChainmail).was_not_called()
end)

it("does not queue take off for coifs", function()
    local factory = makeFactory({ features = "helmet_only" })
    factory.onTalkEvent:handle(factory.twinEntity)
    assert.spy(factory.onTalkEvent.takeOffCoif).was_not_called()
end)

it("triggers talk ended event", function()
    local factory = makeFactory({ features = "helmet_only" })
    factory.onTalkEvent:handle(factory.twinEntity)
    assert.spy(factory.onTalkEvent.handleTalkEndedEvent)
          .was_called_with(
            match.is_ref(factory.onTalkEvent),
            "triggeredByHandler"
    )
end)

describe("ranged feature", function()
    local features = { "helmet_only", "ranged" }
    it("triggers take off first ranged weapon", function()
        local factory = makeFactory({ features = features })
        factory.onTalkEvent:handle(factory.twinEntity)
        assert.spy(factory.onTalkEvent.takeOffFirstRangedWeapon).was_called(1)
    end)

    it("triggers talk ended event", function()
        local factory = makeFactory({ features = features })
        factory.onTalkEvent:handle(factory.twinEntity)
        assert.spy(factory.onTalkEvent.handleTalkEndedEvent)
              .was_called_with(
                match.is_ref(factory.onTalkEvent),
                "triggeredByRanged"
        )
    end)
end)

function makeFactory(args)
    local createFactory = dofile("tests/main/Data/Scripts/HelmetOffDialog/OnTalkEvent/OnTalkEvent_Factory.lua")

    return createFactory(mock, spy, args)
end