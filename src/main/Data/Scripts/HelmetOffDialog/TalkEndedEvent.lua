--- @class TalkEndedEvent
--- @field log Log
--- @field equipment Equipment
--- @field timedTrigger TimedTrigger
--- @field human _G.player.human
--- @field helmetOffDialog HelmetOffDialog
local TalkEndedEvent = {
    new = function(self, helmetOffDialog, log, equipment, timedTrigger, human)
        if helmetOffDialog.__factories.talkEndedEvent then
            return helmetOffDialog.__factories.talkEndedEvent
        end
        local instance = {
            log = log,
            equipment = equipment,
            helmetOffDialog = helmetOffDialog,
            timedTrigger = timedTrigger,
            human = human,
        }
        setmetatable(instance, { __index = self })
        helmetOffDialog.__factories.talkEndedEvent = instance
        return instance
    end,

    listen = function(self)
        --- @type TalkEndedEvent
        local this = self
        this.log:info("TalkEndedEvent.listen")

        this.timedTrigger:start(100, function()
            local isInDialog = this.human:IsInDialog()
            return not isInDialog
        end, function()
            this.log:info("Starting put gear on.")
            this.equipment:putOnCoif()
            this:queuePutOnHeadChainmail()
        end)
    end,

    queuePutOnHeadChainmail = function(self)
        --- @type TalkEndedEvent
        local this = self
        this.log:info("TalkEndedEvent.queuePutOnHeadChainmail")

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
        this.log:info("TalkEndedEvent.putOnHelmet")

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
        this.log:info("TalkEndedEvent.queuePutOnFirstRangedWeapon")

        if not this.helmetOffDialog:config():isRanged() then
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
        this.log:info("TalkEndedEvent.queuePutOnSecondRangedWeapon")

        this.timedTrigger:start(50, function()
            return true
        end, function()
            this.equipment:putOnSecondRangedWeapon()
        end)
    end,
}

_G.HelmetOffDialog.ClassRegistry.TalkEndedEvent = TalkEndedEvent

return TalkEndedEvent