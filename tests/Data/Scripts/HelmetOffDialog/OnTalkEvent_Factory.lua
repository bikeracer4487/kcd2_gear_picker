local function makeFactory(mock, spy, args)
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
    elseif args.randomVersion then
        helmetOffDialog.VERSION = "random"
        if args.mockMathRandomToTruthy ~= nil then
            math.random = function()
                return args.mockMathRandomToTruthy and 1 or 0
            end
        end
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

return makeFactory