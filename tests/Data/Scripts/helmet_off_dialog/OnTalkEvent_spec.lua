it("takes off the helmet", function()
    local factory = makeFactory()
    factory.onTalkEvent:handle()
    assert.spy(factory.equipment.takeOffHelmet).was_called(1)
end)

it("calls takeOffHeadChainmail via callback", function()
    local factory = makeFactory()
    factory.onTalkEvent:handle()
    assert.spy(factory.onTalkEvent.takeOffHeadChainmail).was_called(1)
end)

function makeFactory()
    _G.HelmetOffDialog = { ClassRegistry = {}, __factories = {} }
    local OnTalkEvent = dofile("src/Data/Scripts/HelmetOffDialog/OnTalkEvent.lua")
    local Equipment = dofile("src/Data/Scripts/HelmetOffDialog/Equipment.lua")
    local equipment = mock(Equipment, true)
    equipment.takeOffHelmet = spy.new(function(self, callback)
        callback()
    end)
    local log = { info = spy.new(function()
    end) }
    local human = {}
    local timedTrigger = { start = function()
    end }
    local onTalkEvent = OnTalkEvent:new(log, human, timedTrigger, equipment)
    onTalkEvent.takeOffHeadChainmail = spy.new(onTalkEvent.takeOffHeadChainmail)
    return { equipment = equipment, onTalkEvent = onTalkEvent }
end
