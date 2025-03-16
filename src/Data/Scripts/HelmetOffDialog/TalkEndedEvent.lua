--- @class TalkEndedEvent
--- @field log Log
--- @field equipment Equipment
--- @field timedTrigger TimedTrigger
--- @field human _G.player.human
local TalkEndedEvent = {
    new = function(self, helmetOffDialog, log, equipment, timedTrigger, human)
        log:info("TalkEndedEvent.new")

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
        this.log:info("TalkEndedEvent.listen > putOnCoif")

        this.timedTrigger:start(100, function()
            local isInDialog = this.human:IsInDialog()
            this.log:info("isInDialog: " .. tostring(isInDialog))
            return not isInDialog
        end, function()
            this.log:info("Starting put gear on.")
            this.equipment:putOnCoif()
            this:queuePutOnHeadChainmail()

            --- @type Config
            local config = this.helmetOffDialog:config()

            if config:isRanged() then
                this.equipment:putOnFirstRangedWeapon()
                this.equipment:putOnSecondRangedWeapon()
            end
        end)
    end,

    queuePutOnHeadChainmail = function(self)
        --- @type TalkEndedEvent
        local this = self
        this.log:info("TalkEndedEvent.queuePutOnHeadChainmail")

        this.timedTrigger:start(10, function()
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

        this.timedTrigger:start(10, function()
            return true
        end, function()
            this.equipment:putOnHelmet()
        end)
    end,
}

_G.HelmetOffDialog.ClassRegistry.TalkEndedEvent = TalkEndedEvent

return TalkEndedEvent