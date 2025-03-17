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
    config.isHelmetOnly = function()
        return false
    end
    config.isRandom = function()
        return false
    end
    config.isRanged = function()
        return false
    end

    local features = args and args.features or {}
    features = type(features) == "string" and { features } or (features or {})
    local randomCounter

    for _, feature in ipairs(features) do
        if feature == "helmet_only" then
            config.isHelmetOnly = function()
                return true
            end
        elseif feature == "random" then
            config.isRandom = function()
                return true
            end
            if args.mockMathRandomToTruthy ~= nil then
                if args.mockMathRandomToTruthy then
                    randomCounter = 100
                else
                    randomCounter = -100
                end
                math.random = function()
                    if args.mockMathRandomToTruthy then
                        return 1
                    end
                    return 0
                end
            end
        elseif feature == "ranged" then
            config.isRanged = function()
                return true
            end
        end
    end

    helmetOffDialog.config = function()
        return config
    end

    local human = {
        IsInDialog = function(self)
            local isInDialog = true

            if args and args.isInDialog ~= nil then
                isInDialog = args.isInDialog
            end

            return isInDialog
        end
    }

    --- @type OnTalkEvent
    local onTalkEvent = OnTalkEvent:new(
            helmetOffDialog, log, equipment, talkEndedEvent, human
    )
    spy.on(onTalkEvent, "takeOffHeadChainmail")
    spy.on(onTalkEvent, "coif")
    spy.on(onTalkEvent, "takeOffCoif")
    spy.on(onTalkEvent, "takeOffFirstRangedWeapon")
    spy.on(onTalkEvent, "takeOffSecondRangedWeapon")
    spy.on(onTalkEvent, "handleTalkEndedEvent")

    local eventInProgress = false
    if args and args.eventInProgress ~= nil then
        eventInProgress = args.eventInProgress
    end
    onTalkEvent.eventInProgress = eventInProgress
    if randomCounter ~= nil then
        onTalkEvent.randomCounter = randomCounter
    end

    return {
        equipment = equipment,
        onTalkEvent = onTalkEvent,
        talkEndedEvent = talkEndedEvent
    }
end

return makeFactory