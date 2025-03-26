--- @class OnTalkEvent
--- @field log Log
--- @field equipment Equipment
--- @field talkEndedEvent TalkEndedEvent
--- @field metaRole MetaRole
--- @field handle func(self: OnTalkEvent, twinEntity: _G.Entity)
local OnTalkEvent = {
    new = function(self, helmetOffDialog, log, equipment, TalkEndedEvent, player, metaRole)
        if helmetOffDialog.__factories.onTalkEvent then
            return helmetOffDialog.__factories.onTalkEvent
        end
        local instance = {
            helmetOffDialog = helmetOffDialog,
            log = log,
            equipment = equipment,
            talkEndedEvent = TalkEndedEvent,
            player = player,
            metaRole = metaRole,
            eventInProgress = false,
            randomCounter = 0
        }
        setmetatable(instance, { __index = self })
        helmetOffDialog.__factories.onTalkEvent = instance
        return instance
    end,

    handle = function(self, twinEntity)
        --- @type OnTalkEvent
        local this = self
        local log = this.log

        if this.eventInProgress then
            log:info("OnTalkEvent in progress, aborting.")
            return
        end

        local twiName = twinEntity:GetName()
        local entityName = string.gsub(twiName, "DialogTwin_", "")
        log:info('EntityName:', entityName)

        if entityName == "Dude" then
            log:info('Aborting because entity is player.')
            return
        end

        if not this.player.human:IsInDialog() then
            log:info("Aborting because player is not in dialog")
            this.eventInProgress = false
            return
        end

        if this.metaRole:hasBathhouseBooking(entityName) then
            log:info("Aborting because entity serves bathhouse services.")
            return
        end

        --- @type Config
        local config = this.helmetOffDialog:config()

        if config:isRandom() then
            this.log:info("Random feature is enabled.")
            this.randomCounter = this.randomCounter + 1
            local threshold = this.randomCounter * 0.2
            if threshold > 1.0 then
                threshold = 1.0
            end
            if math.random() > threshold then
                this.log:info("Aborting due to random check passing.")
                return
            end
            this.log:info("Not aborting due to random check failing ")
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
        --- @type OnTalkEvent
        local this = self
        this.talkEndedEvent:listen()
        this.log:info("OnTalkEvent: finished")
        this.eventInProgress = false
        this.randomCounter = 0
    end,
}

_G.HelmetOffDialog.ClassRegistry.OnTalkEvent = OnTalkEvent
return OnTalkEvent