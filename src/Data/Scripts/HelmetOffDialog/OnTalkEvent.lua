--- @class OnTalkEvent
local OnTalkEvent = {
    --- @field new fun(self: OnTalkEvent, log: Log, human: _G.player.human, timedTrigger: TimedTrigger, equipment: Equipment): OnTalkEvent
    new = function(self, log, human, timedTrigger, equipment)
        if HelmetOffDialog.__factories.onTalkEvent then
            return HelmetOffDialog.__factories.onTalkEvent
        end
        local instance = {
            --- @field log Log
            log = log,
            --- @field human _G.player.human
            human = human,
            --- @field timedTrigger TimedTrigger
            timedTrigger = timedTrigger,
            --- @field equipment Equipment
            equipment = equipment
        }
        setmetatable(instance, { __index = self })
        HelmetOffDialog.__factories.onTalkEvent = instance
        return instance
    end,

    --- @field handle fun(self: OnTalkEvent)
    handle = function(self)
        --- @type OnTalkEvent
        local this = self
        this.log:info("OnTalkEvent.handle called")
        this.equipment:takeOffHelmet(function()
            this:takeOffHeadChainmail()
        end)
    end,

    --- @field takeOffHeadChainmail fun(self: OnTalkEvent)
    takeOffHeadChainmail = function(self)
    end
}

HelmetOffDialog.ClassRegistry.OnTalkEvent = OnTalkEvent

return OnTalkEvent