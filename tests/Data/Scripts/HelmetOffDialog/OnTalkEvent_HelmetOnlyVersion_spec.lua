describe("helmet: ", function()
    it("takes it off", function()
        local factory = makeFactory({ helmetOnlyVersion = true })
        factory.onTalkEvent:handle()
        assert.spy(factory.equipment.takeOffHelmet).was_called(1)
    end)
    it("does not queue take off for head chainmail", function()
        local factory = makeFactory({ helmetOnlyVersion = true })
        factory.onTalkEvent:handle()
        assert.spy(factory.onTalkEvent.takeOffHeadChainmail).was_not_called()
    end)
    it("does not queue take off for coifs", function()
        local factory = makeFactory({ helmetOnlyVersion = true })
        factory.onTalkEvent:handle()
        assert.spy(factory.onTalkEvent.takeOffCoif).was_not_called()
    end)
    it("triggers talk ended event", function()
        local factory = makeFactory({ helmetOnlyVersion = true })
        factory.onTalkEvent:handle()
        assert.spy(factory.talkEndedEvent.listen).was_called(1)
    end)
end)

function makeFactory(args)
    dofile("src/Data/Scripts/HelmetOffDialog/utils/dd.lua")
    local mockHelmetOffDialog = dofile("tests/HodMock.lua")
    local helmetOffDialogFactory = mockHelmetOffDialog(mock, spy)
    local helmetOffDialog = helmetOffDialogFactory.HelmetOffDialog
    local OnTalkEvent = dofile("src/Data/Scripts/HelmetOffDialog/OnTalkEvent.lua")
    local Equipment = dofile("src/Data/Scripts/HelmetOffDialog/Equipment.lua")
    local equipment = mock(Equipment, true)
    equipment.takeOffHelmet = spy.new(function(self, callback)
        callback()
    end)
    equipment.takeOffHeadChainmail = spy.new(function(self, callback)
        callback()
    end)
    equipment.takeOffCoif = spy.new(function(self, callback)
        callback()
    end)
    local TalkEndedEvent = dofile("src/Data/Scripts/HelmetOffDialog/TalkEndedEvent.lua")
    local talkEndedEvent = mock(TalkEndedEvent, true)
    local log = { info = spy.new(function()
    end) }

    args = args or {}
    if args.helmetOnlyVersion then
        helmetOffDialog.VERSION = "helmet_only"
    else
        helmetOffDialog.VERSION = "default"
    end

    local onTalkEvent = OnTalkEvent:new(helmetOffDialog, log, equipment, talkEndedEvent)
    spy.on(onTalkEvent, "takeOffHeadChainmail")
    spy.on(onTalkEvent, "coif")
    spy.on(onTalkEvent, "takeOffCoif")
    return {
        equipment = equipment,
        onTalkEvent = onTalkEvent,
        talkEndedEvent = talkEndedEvent
    }
end