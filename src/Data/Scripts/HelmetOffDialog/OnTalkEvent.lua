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
        --- @type Config
        local config = this.helmetOffDialog:config()

        if config:isRandom() then
            local randomValue = math.random(0, 1)
            if randomValue == 0 then
                this.log:info("Random check failed, all features aborted")
                return
            end
        end

        this.equipment:takeOffHelmet(function()
            if config:isHelmetOnly() then
                this.talkEndedEvent:listen()
                return
            end
            this:takeOffHeadChainmail()
        end)


        if config:isRanged() then
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
        this.equipment:takeOffSecondRangedWeapon(function()
            this.talkEndedEvent:listen()
        end)
    end
}

_G.HelmetOffDialog.ClassRegistry.OnTalkEvent = OnTalkEvent

return OnTalkEvent