--- @class Quest
--- @field log Log
--- @field calendar _G.Calendar
--- @field math _G.math
--- @field isOnSecondWorldDay func(self: Quest, entity: Entity)
local Quest = {
    new = function(self, helmetOffDialog, log, calendar, math)
        if helmetOffDialog.__factories.Quest then
            return helmetOffDialog.__factories.Quest
        end
        local instance = {
            helmetOffDialog = helmetOffDialog,
            log = log,
            calendar = calendar,
            math = math
        }
        setmetatable(instance, { __index = self })
        helmetOffDialog.__factories.Quest = instance
        log:info("Quest New instance created")
        return instance
    end,

    isOnSecondWorldDay = function(self)
        --- @type Quest
        local this = self
        local log = this.log
        local checkMsg = "Checking if quest 'Easy Riders', with objective "
                .. "to get kitted is pending"
        log:info(checkMsg)

        local worldDay = tostring(this.calendar.GetWorldDay())
        local isEasyRidersQuestDay = worldDay == "2"

        if isEasyRidersQuestDay then
            log:info("Truthy due quest day: ", worldDay)
            return true
        end

        log:info("Falsy due to invalid quest day: ", worldDay)
        return false
    end,
}

_G.HelmetOffDialog.ClassRegistry.Quest = Quest