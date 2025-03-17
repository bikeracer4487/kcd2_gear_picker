-- todo handle not in dialogue
-- todo handle event already in progress
it("takes off helmet", function()
    local factory = makeFactory()
    factory.onTalkEvent:handle()
    assert.spy(factory.equipment.takeOffHelmet).was_called(1)
end)

it("queues take off for head chainmail", function()
    local factory = makeFactory()
    factory.onTalkEvent:handle()
    assert.spy(factory.onTalkEvent.takeOffHeadChainmail).was_called(1)
end)

it("takes off head chainmail", function()
    local factory = makeFactory()
    factory.onTalkEvent:takeOffHeadChainmail()
    assert.spy(factory.equipment.takeOffHeadChainmail).was_called(1)
end)

it("queues take off for coif", function()
    local factory = makeFactory()
    factory.onTalkEvent:takeOffHeadChainmail()
    assert.spy(factory.onTalkEvent.takeOffCoif).was_called(1)
end)

it("take off coif", function()
    local factory = makeFactory()
    factory.onTalkEvent:takeOffCoif()
    assert.spy(factory.equipment.takeOffCoif).was_called(1)
end)

it("triggers talk ended event", function()
    local factory = makeFactory()
    factory.onTalkEvent:takeOffCoif()
    assert.spy(factory.talkEndedEvent.listen).was_called(1)
end)

function makeFactory(args)
    local createFactory = dofile("tests/main/Data/Scripts/HelmetOffDialog/OnTalkEvent/OnTalkEvent_Factory.lua")

    return createFactory(mock, spy, args)
end
