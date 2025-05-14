--- @class TimedTrigger
--- @field new fun(self: TimedTrigger, script: Script.SetTimer): TimedTrigger
--- @field start fun(self: TimedTrigger, intervalMs: number, checkCallback: function, runCallback: function)
--- @field script Script
local TimedTrigger = {
    setTimer = nil,
    new = function(self, script)
        local instance = { script = script, }
        setmetatable(instance, { __index = self })

        return instance
    end,

    start = function(self, intervalMs, checkCallback, runCallback)
        --- @type TimedTrigger
        local this = self

        this.script.SetTimer(intervalMs, function()
            if checkCallback() then
                runCallback()
            else
                this:start(intervalMs, checkCallback, runCallback)
            end
        end)
    end,
}

-- Register with GearPicker class registry
GearPicker.ClassRegistry.TimedTrigger = TimedTrigger

return TimedTrigger