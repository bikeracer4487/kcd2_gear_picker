local Log = HelmetOffDialog.Log

--- @class OnTalkEvent
--- @field equipment Equipment
--- @field talkEndedEvent TalkEndedEvent
--- @field metaRole MetaRole
--- @field config Config
local OnTalkEvent = {
    new = function(self, equipment, talkEndedEvent, metaRole, config)
        local instance = {
            equipment = equipment,
            talkEndedEvent = talkEndedEvent,
            metaRole = metaRole,
            config = config,
            eventInProgress = false,
            randomCounter = 0
        }
        setmetatable(instance, { __index = self })
        return instance
    end,

    --- @field handle func(self: OnTalkEvent, entityName: _G.Entity)
    handle = function(self, twinEntity, player)
        ----- @type OnTalkEvent
        local this = self

        if this.eventInProgress then
            Log.info("OnTalkEvent in progress, aborting.")
            return
        end

        if this.config:isModOff() then
            Log.info("Aborting because mod is turned off")
            return
        end

        local twinName = twinEntity:GetName()
        local entityName = string.gsub(twinName, "DialogTwin_", "")
        Log.info('EntityName:', entityName)

        if entityName == "Dude" then
            Log.info('Aborting because entity is player.')
            return
        end

        if not player.human:IsInDialog() then
            Log.info("Aborting because player is not in dialog")
            this.eventInProgress = false
            return
        end

        if this.metaRole:hasBathhouseBooking(twinEntity, player) then
            Log.info("Aborting because entity serves bathhouse services.")
            return
        end

        if this.config:isRandom() then
            Log.info("Random feature is enabled.")
            this.randomCounter = this.randomCounter + 1
            local threshold = this.randomCounter * 0.2
            if threshold > 1.0 then
                threshold = 1.0
            end
            if math.random() > threshold then
                Log.info("Aborting due to random check passing.")
                return
            end
            Log.info("Not aborting due to random check failing ")
        end

        if this.config:isRanged() and this.metaRole:hasArcheryCompetition(entityName) then
            Log.info("Aborting taking off gear because entity offers archery competition.")
            return
        end

        this.eventInProgress = true

        this.equipment:takeOffHelmet(function()
            if not this.config:isHelmetOnly() then
                this:takeOffHeadChainmail(entityName)
            elseif this.config:isRanged() then
                this:takeOffFirstRangedWeapon(entityName)
            else
                this:handleTalkEndedEvent("triggeredByHandler")
            end
        end)
    end,

    takeOffHeadChainmail = function(self, entity)
        local this = self
        Log.info("OnTalkEvent.takeOffHeadChainmail")
        this.equipment:takeOffHeadChainmail(function()
            this:takeOffCoif(entity)
        end)
    end,

    takeOffCoif = function(self, entityName)
        --- OnTalkEvent
        local this = self
        Log.info("OnTalkEvent.takeOffCoif")
        this.equipment:takeOffCoif(function()
            if this.config:isRanged() then
                this:takeOffFirstRangedWeapon(entityName)
            else
                this:handleTalkEndedEvent("triggeredByTakeOffCoif")
            end
        end)
    end,

    takeOffFirstRangedWeapon = function(self, entityName)
        --- @type OnTalkEvent
        local this = self
        Log.info("OnTalkEvent.takeOffFirstRangedWeapon")

        this.equipment:takeOffFirstRangedWeapon(function()
            this:takeOffSecondRangedWeapon()
        end)
    end,

    takeOffSecondRangedWeapon = function(self)
        --- @type OnTalkEvent
        local this = self
        Log.info("OnTalkEvent.takeOffSecondRangedWeapon")
        this.equipment:takeOffSecondRangedWeapon(function()
            this:handleTalkEndedEvent("triggeredByRanged")
        end)
    end,

    handleTalkEndedEvent = function(self)
        --- @type OnTalkEvent
        local this = self
        this.talkEndedEvent:listen()
        Log.info("OnTalkEvent: finished")
        this.eventInProgress = false
        this.randomCounter = 0
    end,
}

_G.HelmetOffDialog.ClassRegistry.OnTalkEvent = OnTalkEvent
return OnTalkEvent