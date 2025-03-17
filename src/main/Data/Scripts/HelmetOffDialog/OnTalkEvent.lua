--- @class OnTalkEvent
--- @field log Log
--- @field equipment Equipment
--- @field talkEndedEvent TalkEndedEvent
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
            eventInProgress = false
        }
        setmetatable(instance, { __index = self })
        helmetOffDialog.__factories.onTalkEvent = instance
        return instance
    end,

    handle = function(self)
        --- @type OnTalkEvent
        local this = self
        local isInDialog = this.human:IsInDialog()

        if not isInDialog then
            this.log:info("Not in dialogue. Aborting.")
            this.eventInProgress = false
            return
        end

        if self.eventInProgress == true then
            this.log:info("OnTalkEvent in progress, aborting.")
            return
        end

        --- @type Config
        local config = this.helmetOffDialog:config()

        if config:isRandom() then
            this.log:info("Random feature is enabled.")
            local randomValue = math.random(0, 1)
            if randomValue == 0 then
                this.log:info("Random check failed, all features aborted")
                return
            end
        end

        self.eventInProgress = true

        this.equipment:takeOffHelmet(function()
            if not config:isHelmetOnly() then
                this:takeOffHeadChainmail()
                return
            end

            if config:isRanged() then
                this:takeOffFirstRangedWeapon()
            else
                this:handleTalkEndedEvent()
            end
        end)
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
        --- @type Config
        local config = this.helmetOffDialog:config()

        this.equipment:takeOffCoif(function()
            local isRanged = config:isRanged()
            if isRanged then
                this:takeOffFirstRangedWeapon()
                return
            end

            this:handleTalkEndedEvent()
        end)
    end,

    takeOffFirstRangedWeapon = function(self)
        --- @type OnTalkEvent
        local this = self
        this.log:info("OnTalkEvent.takeOffFirstRangedWeapon")
        this.equipment:takeOffFirstRangedWeapon(function()
            this:takeOffSecondRangedWeapon()
        end)
    end,

    takeOffSecondRangedWeapon = function(self)
        --- @type OnTalkEvent
        local this = self
        this.log:info("OnTalkEvent.takeOffSecondRangedWeapon")
        this.equipment:takeOffSecondRangedWeapon(function()
            this:handleTalkEndedEvent()
        end)
    end,
    handleTalkEndedEvent = function(self)
        --- @type OnTalkEvent
        local this = self
        this.talkEndedEvent:listen()
        this.log:info("OnTalkEvent: finished")
        this.eventInProgress = false
    end
}

_G.HelmetOffDialog.ClassRegistry.OnTalkEvent = OnTalkEvent

return OnTalkEvent