local function makeFactory(mock, spy, args)
    dofile("src/main/Data/Scripts/HelmetOffDialog/utils/dd.lua")
    local mockHelmetOffDialog = dofile("tests/main/HelmetOffDialogMock.lua")
    local helmetOffDialogFactory = mockHelmetOffDialog(mock, spy)
    local helmetOffDialog = helmetOffDialogFactory.HelmetOffDialog
    local OnTalkEvent = dofile("src/main/Data/Scripts/HelmetOffDialog/OnTalkEvent.lua")
    local Log = dofile("src/main/Data/Scripts/HelmetOffDialog/utils/Log.lua")

    local log = mock(Log, true)

    local TalkEndedEvent = dofile("src/main/Data/Scripts/HelmetOffDialog/TalkEndedEvent.lua")
    local talkEndedEvent = mock(TalkEndedEvent, true)

    local Equipment = dofile("src/main/Data/Scripts/HelmetOffDialog/Equipment.lua")
    local equipment = mock(Equipment, true)

    equipment.log = function()
        return log
    end
    equipment.takeOffHelmet = spy.new(function(self, callback)
        callback()
    end)
    equipment.takeOffHeadChainmail = spy.new(function(self, callback)
        callback()
    end)
    equipment.takeOffCoif = spy.new(function(self, callback)
        callback()
    end)
    equipment.takeOffFirstRangedWeapon = spy.new(function(self, callback)
        callback()
    end)
    equipment.takeOffSecondRangedWeapon = spy.new(function(self, callback)
        callback()
    end)

    local Config = dofile("src/main/Data/Scripts/HelmetOffDialog/Config.lua")
    --- @type Config
    local config = mock(Config, true)

    args = args or {}
    if args.target == "helmet_only" then
        config.isHelmetOnly = function()
            return true
        end
    elseif args.target == "random" then
        config.isRandom = function()
            return true
        end
        if args.mockMathRandomToTruthy ~= nil then
            math.random = function()
                return args.mockMathRandomToTruthy and 1 or 0
            end
        end
    elseif args.target == "ranged" then
        config.isRanged = function()
            return true
        end
    end

    helmetOffDialog.config = function()
        return config
    end

    --- @type OnTalkEvent
    local onTalkEvent = OnTalkEvent:new(
            helmetOffDialog, log, equipment, talkEndedEvent
    )
    spy.on(onTalkEvent, "takeOffHeadChainmail")
    spy.on(onTalkEvent, "coif")
    spy.on(onTalkEvent, "takeOffCoif")
    spy.on(onTalkEvent, "takeOffFirstRangedWeapon")
    spy.on(onTalkEvent, "takeOffSecondRangedWeapon")

    return {
        equipment = equipment,
        onTalkEvent = onTalkEvent,
        talkEndedEvent = talkEndedEvent
    }
end

return makeFactory