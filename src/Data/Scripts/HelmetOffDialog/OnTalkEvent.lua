--- @class OnTalkEvent
--- @field log Log
--- @field equipment Equipment
--- @field talkEndedEvent TalkEndedEvent
local OnTalkEvent = {
    new = function(self, helmetOffDialog, log, equipment, TalkEndedEvent)
        log:info("OnTalkEvent.new")

        if helmetOffDialog.__factories.onTalkEvent then
            return helmetOffDialog.__factories.onTalkEvent
        end
        local instance = {
            log = log,
            equipment = equipment,
            helmetOffDialog = helmetOffDialog,
            talkEndedEvent = TalkEndedEvent,
        }
        setmetatable(instance, { __index = self })
        helmetOffDialog.__factories.onTalkEvent = instance
        return instance
    end,

    handle = function(self)
        --- @type OnTalkEvent
        local this = self
        this.log:info("OnTalkEvent.handle")

        if this.helmetOffDialog.VARIANT == "random" then
            local randomValue = math.random(0, 1)
            if randomValue == 0 then
                this.log:info("Random check failed, helmet removal aborted")
                return
            end
        end

        this.equipment:takeOffHelmet(function()
            if this.helmetOffDialog.VARIANT == "helmet_only" then
                this.talkEndedEvent:listen()
                return
            end
            this:takeOffHeadChainmail()
        end)

        if this.helmetOffDialog.VARIANT == "ranged_weapons" then
            this.equipment:takeOffFirstRangedWeapon(function()
                this:takeOffSecondRangedWeapon()
            end)
        end
    end,

    takeOffHeadChainmail = function(self)
        --- @type OnTalkEvent
        local this = self
        this.log:info("OnTalkEvent.takeOffHeadChainmail")
        this.equipment:takeOffHeadChainmail(function()
            this:takeOffCoif()
        end)
    end,

    takeOffCoif = function(self)
        --- @type OnTalkEvent
        local this = self
        this.log:info("OnTalkEvent.takeOffCoif")
        this.equipment:takeOffCoif(function()
            this.talkEndedEvent:listen()
        end)
    end,

    takeOffSecondRangedWeapon = function(self)
        --- @type OnTalkEvent
        local this = self
        this.log:info("OnTalkEvent.takeOffSecondRangedWeapon")
        --this.equipment:takeOffCoif(function()
        --    this.talkEndedEvent:listen()
        --end)
    end
}

_G.HelmetOffDialog.ClassRegistry.OnTalkEvent = OnTalkEvent

return OnTalkEvent