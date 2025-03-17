it("takes off helmet", function()
    local factory = makeFactory({ target = "helmet_only" })
    factory.onTalkEvent:handle()
    assert.spy(factory.equipment.takeOffHelmet).was_called(1)
end)

it("does not queue take off for head chainmail", function()
    local factory = makeFactory({ target = "helmet_only" })
    factory.onTalkEvent:handle()
    assert.spy(factory.onTalkEvent.takeOffHeadChainmail).was_not_called()
end)

it("does not queue take off for coifs", function()
    local factory = makeFactory({ target = "helmet_only" })
    factory.onTalkEvent:handle()
    assert.spy(factory.onTalkEvent.takeOffCoif).was_not_called()
end)

it("triggers talk ended event", function()
    local factory = makeFactory({ target = "helmet_only" })
    factory.onTalkEvent:handle()
    assert.spy(factory.talkEndedEvent.listen).was_called(1)
end)

function makeFactory(args)
    local createFactory = dofile("tests/main/Data/Scripts/HelmetOffDialog/OnTalkEvent/OnTalkEvent_Factory.lua")

    return createFactory(mock, spy, args)
end