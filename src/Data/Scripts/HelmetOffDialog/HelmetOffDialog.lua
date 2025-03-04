--- @class HelmetOffDialog
HelmetOffDialog = {
    MOD_NAME = "__DYNAMICALLY_INJECTED__",
    HOD_ENVIRONMENT = "__DYNAMICALLY_INJECTED__",

    ClassRegistry = {},
    __factories = {},

    config = function(self)
        --- @type Config
        local Config = self.ClassRegistry.Config
        return Config:new(self.HOD_ENVIRONMENT)
    end,
    log = function(self)
        local config = self:config()
        --- @type Log
        local Log = self.ClassRegistry.Log
        return Log:new(self.MOD_NAME, config)
    end,
    equipment = function(self)
        --- @type HelmetOffDialog
        local this = self
        local log = this:log()
        --- @type Equipment
        local Equipment = this.ClassRegistry.Equipment
        local equippedItem = this:equippedItem()
        return Equipment:new(log, _G.player, equippedItem)
    end,
    error = function(self)
        --- @type HelmetOffDialog
        local this = self
        local log = this:log()
        --- @type Error
        local Error = this.ClassRegistry.Error
        return Error:new(log)
    end,
    onTalkEvent = function(self)
        --- @type HelmetOffDialog
        local this = self
        local log = this:log()
        local timedTrigger = this:timedTrigger()
        local equipment = this:equipment()
        --- @type OnTalkEvent
        local OnTalkEvent = this.ClassRegistry.OnTalkEvent
        return OnTalkEvent:new(this, log, _G.player.human, timedTrigger, equipment)
    end,
    timedTrigger = function(self)
        --- @type HelmetOffDialog
        local this = self
        local log = this:log()
        --- @type TimedTrigger
        local TimedTrigger = this.ClassRegistry.TimedTrigger
        return TimedTrigger:new(log, _G.Script)
    end,
    equippedItem = function(self)
        --- @type HelmetOffDialog
        local this = self
        local log = this:log()
        --- @type EquippedItem
        local EquippedItem = this.ClassRegistry.EquippedItem
        return EquippedItem:new(log, _G.player, _G.Script)
    end,

    init = function(self)
        System.LogAlways(self.MOD_NAME .. ": Initializing HelmetOffDialog")
        local modName = HelmetOffDialog.MOD_NAME
        local scripts = {
            string.format("Scripts/%s/utils/Log.lua", modName),
            string.format("Scripts/%s/utils/Error.lua", modName),
            string.format("Scripts/%s/utils/TimedTrigger.lua", modName),
            string.format("Scripts/%s/Config.lua", modName),
            string.format("Scripts/%s/Equipment.lua", modName),
            string.format("Scripts/%s/OnTalkEvent.lua", modName),
            string.format("Scripts/%s/EquippedItem.lua", modName),
        }
        for _, script in ipairs(scripts) do
            local result = Script.LoadScript(script)
            if result ~= 1 then
                System.LogAlways("$4[" .. HelmetOffDialog.MOD_NAME .. ".ERROR] Unable to load script: " .. script)
            end
        end
        System.LogAlways("$5[" .. HelmetOffDialog.MOD_NAME .. ".INFO] All classes loaded.")
    end
}

HelmetOffDialog:init()