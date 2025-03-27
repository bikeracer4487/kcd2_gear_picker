local Log = HelmetOffDialog.Log

--- @class TalkEndedEvent
--- @field equipment Equipment
--- @field timedTrigger TimedTrigger
--- @field config Config
--- @field player _G.player
local TalkEndedEvent = {
    new = function(self, config, equipment, timedTrigger, player)
        local instance = {
            config = config,
            equipment = equipment,
            timedTrigger = timedTrigger,
            player = player,
        }
        setmetatable(instance, { __index = self })
        return instance
    end,

    listen = function(self)
        --- @type TalkEndedEvent
        local this = self
        Log.info("TalkEndedEvent.listen")

        this.timedTrigger:start(200, function()
            local isInDialog = this.player.human:IsInDialog()
            Log.info("isInDialog", isInDialog)
            local hasEquippedGear = tostring(this.player.soul:GetDerivedStat("eqw")) ~= "0"
            Log.info("hasEquippedGear", hasEquippedGear)
            return not isInDialog and hasEquippedGear
        end, function()
            Log.info("Starting put gear on.")
            this.equipment:putOnCoif()
            this:queuePutOnHeadChainmail()
        end)
    end,

    forcePutOn = function(self)
        --- @type TalkEndedEvent
        local this = self
        Log.info("TalkEndedEvent.force")

        this.equipment:putOnCoif()
        this.equipment:putOnHeadChainmail()
        this.equipment:putOnHelmet()
        this.equipment:putOnFirstRangedWeapon()
        this.equipment:putOnSecondRangedWeapon()
    end,

    queuePutOnHeadChainmail = function(self)
        --- @type TalkEndedEvent
        local this = self
        Log.info("TalkEndedEvent.queuePutOnHeadChainmail")

        this.timedTrigger:start(50, function()
            return true
        end, function()
            this.equipment:putOnHeadChainmail()
            this:queuePutOnHelmet()
        end)
    end,

    queuePutOnHelmet = function(self)
        --- @type TalkEndedEvent
        local this = self
        Log.info("TalkEndedEvent.putOnHelmet")

        this.timedTrigger:start(50, function()
            return true
        end, function()
            this.equipment:putOnHelmet()
            this:queuePutOnFirstRangedWeapon()
        end)
    end,

    queuePutOnFirstRangedWeapon = function(self)
        --- @type TalkEndedEvent
        local this = self
        Log.info("TalkEndedEvent.queuePutOnFirstRangedWeapon")

        if not this.config():isRanged() then
            return
        end

        this.timedTrigger:start(50, function()
            return true
        end, function()
            this.equipment:putOnFirstRangedWeapon()
            this:queuePutOnSecondRangedWeapon()
        end)
    end,

    queuePutOnSecondRangedWeapon = function(self)
        --- @type TalkEndedEvent
        local this = self
        Log.info("TalkEndedEvent.queuePutOnSecondRangedWeapon")

        this.timedTrigger:start(50, function()
            return true
        end, function()
            this.equipment:putOnSecondRangedWeapon()
        end)
    end,
}

_G.HelmetOffDialog.ClassRegistry.TalkEndedEvent = TalkEndedEvent

return TalkEndedEvent