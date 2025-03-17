local OnTalkEvent = {
    new = function(self, helmetOffDialog, log, equipment, TalkEndedEvent, human)
        if helmetOffDialog.__factories.onTalkEvent then
            return helmetOffDialog.__factories.onTalkEvent
        end
        local instance = {
            helmetOffDialog = helmetOffDialog,
            log = log,
            equipment = equipment,
            talkEndedEvent = TalkEndedEvent,
            human = human,
            eventInProgress = false,
            randomCounter = 0
        }
        setmetatable(instance, { __index = self })
        helmetOffDialog.__factories.onTalkEvent = instance
        return instance
    end,

    handle = function(self)
        local this = self
        if not this.human:IsInDialog() then
            this.log:info("Not in dialogue. Aborting.")
            this.eventInProgress = false
            return
        end

        if this.eventInProgress then
            this.log:info("OnTalkEvent in progress, aborting.")
            return
        end

        local config = this.helmetOffDialog:config()
        if config:isRandom() then
            this.log:info("Random feature is enabled.")
            this.randomCounter = this.randomCounter + 1
            local threshold = this.randomCounter * 0.2
            if threshold > 1.0 then threshold = 1.0 end  -- Cap at 100%
            if math.random() > threshold then
                this.log:info("Random check failed, counter: " .. this.randomCounter)
                return
            end
            this.log:info("Random check passed, counter: " .. this.randomCounter)
        end

        this.eventInProgress = true

        this.equipment:takeOffHelmet(function()
            if not config:isHelmetOnly() then
                this:takeOffHeadChainmail()
            elseif config:isRanged() then
                this:takeOffFirstRangedWeapon()
            else
                this:handleTalkEndedEvent("triggeredByHandler")
            end
        end)
    end,

    takeOffHeadChainmail = function(self)
        local this = self
        this.log:info("OnTalkEvent.takeOffHeadChainmail")
        this.equipment:takeOffHeadChainmail(function()
            this:takeOffCoif()
        end)
    end,

    takeOffCoif = function(self)
        local this = self
        this.log:info("OnTalkEvent.takeOffCoif")
        local config = this.helmetOffDialog:config()
        this.equipment:takeOffCoif(function()
            if config:isRanged() then
                this:takeOffFirstRangedWeapon()
            else
                this:handleTalkEndedEvent("triggeredByTakeOffCoif")
            end
        end)
    end,

    takeOffFirstRangedWeapon = function(self)
        local this = self
        this.log:info("OnTalkEvent.takeOffFirstRangedWeapon")
        this.equipment:takeOffFirstRangedWeapon(function()
            this:takeOffSecondRangedWeapon()
        end)
    end,

    takeOffSecondRangedWeapon = function(self)
        local this = self
        this.log:info("OnTalkEvent.takeOffSecondRangedWeapon")
        this.equipment:takeOffSecondRangedWeapon(function()
            this:handleTalkEndedEvent("triggeredByRanged")
        end)
    end,

    handleTalkEndedEvent = function(self)
        local this = self
        this.talkEndedEvent:listen()
        this.log:info("OnTalkEvent: finished")
        this.eventInProgress = false
        this.randomCounter = 0
    end
}

_G.HelmetOffDialog.ClassRegistry.OnTalkEvent = OnTalkEvent
return OnTalkEvent