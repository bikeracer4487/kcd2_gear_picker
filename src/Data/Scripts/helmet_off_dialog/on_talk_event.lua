--- @class OnTalkEvent
--- @field new fun(self: OnTalkEvent, log: Log, human: _G.player.human, timedTrigger: TimedTrigger, equipment: Equipment): OnTalkEvent
--- @field handle fun(self: OnTalkEvent)
--- @field log Log
--- @field human _G.player.human
--- @field timedTrigger TimedTrigger
--- @field equipment Equipment

local OnTalkEvent = {
    log = nil,
    human = nil,
    timedTrigger = nil,
    equipment = nil,

    new = function(self, log, human, timedTrigger, equipment)
        if HelmetOffDialog.__factories.onTalkEvent then
            return HelmetOffDialog.__factories.onTalkEvent
        end
        local instance = {
            log = log,
            human = human,
            timedTrigger = timedTrigger,
            equipment = equipment
        }
        setmetatable(instance, { __index = self })
        HelmetOffDialog.__factories.onTalkEvent = instance
        return instance
    end,

    handle = function(self)
        --- @type OnTalkEvent
        local this = self

        this.log:info("OnTalkEvent.handle called")

        this.equipment:unequipHelmet()
        this.equipment:unequipHeadChainmail()
        this.equipment:unequipCoif()

        local callbackRun = function()
            this.equipment:equipCoif()
            this.timedTrigger:start(200, function()
                return true
            end, function()
                this.equipment:equipHeadChainmail()
                this.timedTrigger:start(200, function()
                    return true
                end, function()
                    this.equipment:equipHelmet()
                end)
            end)
        end

        this.timedTrigger:start(1000, function()
            return not this.human:IsInDialog()
        end, callbackRun)
    end
}

HelmetOffDialog.ClassRegistry.OnTalkEvent = OnTalkEvent