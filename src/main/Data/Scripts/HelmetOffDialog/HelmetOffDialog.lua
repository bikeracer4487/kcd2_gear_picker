--- @class HelmetOffDialog @global
local HelmetOffDialog = {
    MOD_NAME = "__DYNAMICALLY_INJECTED__",
    HOD_ENVIRONMENT = "__DYNAMICALLY_INJECTED__",

    ClassRegistry = {},
    __factories = {},

    --- @type Config
    config = function(self)
        --- @type Config
        local Config = self.ClassRegistry.Config
        return Config:new(self.HOD_ENVIRONMENT)
    end,
    --- @type Log
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
        local unequipGear = this:unequipGear()
        --- @type Equipment
        local Equipment = this.ClassRegistry.Equipment
        return Equipment:new(this, log, _G.player, unequipGear)
    end,
    unequipGear = function(self)
        --- @type HelmetOffDialog
        local this = self
        --- @type UnequipGear
        local UnequipGear = this.ClassRegistry.UnequipGear
        return UnequipGear:new(
                this,
                this:log(),
                _G.player.actor,
                this:equippedItem(),
                this:itemCategory(),
                _G.ItemManager,
                _G.player.inventory
        )
    end,
    error = function(self)
        --- @type HelmetOffDialog
        local this = self
        local log = this:log()
        --- @type Error
        local Error = this.ClassRegistry.Error
        return Error:new(log)
    end,
    talkEndedEvent = function(self)
        --- @type HelmetOffDialog
        local this = self
        local log = this:log()
        local equipment = this:equipment()
        local timedTrigger = this:timedTrigger()
        --- @type TalkEndedEvent
        local TalkEndedEvent = this.ClassRegistry.TalkEndedEvent
        return TalkEndedEvent:new(this, log, equipment, timedTrigger, _G.player)
    end,
    metaRole = function(self)
        --- @type HelmetOffDialog
        local this = self
        local log = this:log()
        --- @type MetaRole
        local MetaRole = this.ClassRegistry.MetaRole
        return MetaRole:new(this, log)
    end,
    onTalkEvent = function(self)
        --- @type HelmetOffDialog
        local this = self
        local log = this:log()
        local equipment = this:equipment()
        --- @type TalkEndedEvent
        local talkEndedEvent = this:talkEndedEvent()
        --- @type MetaRole
        local metaRole = this:metaRole()
        --- @type OnTalkEvent
        local OnTalkEvent = this.ClassRegistry.OnTalkEvent
        return OnTalkEvent:new(this, log, equipment, talkEndedEvent, _G.player, metaRole)
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
        return EquippedItem:new(this, log, _G.player, _G.Script)
    end,
    itemCategory = function(self)
        --- @type HelmetOffDialog
        local this = self
        local log = this:log()
        --- @type ItemCategory
        local ItemCategory = this.ClassRegistry.ItemCategory
        return ItemCategory:new(this, log, _G.ItemManager)
    end,

    init = function(self)
        local modName = "HelmetOffDialog"
        local scripts = {
            string.format("Scripts/%s/utils/Log.lua", modName),
            string.format("Scripts/%s/utils/Error.lua", modName),
            string.format("Scripts/%s/utils/TimedTrigger.lua", modName),
            string.format("Scripts/%s/Config.lua", modName),
            string.format("Scripts/%s/Equipment.lua", modName),
            string.format("Scripts/%s/EquippedItem.lua", modName),
            string.format("Scripts/%s/OnTalkEvent.lua", modName),
            string.format("Scripts/%s/TalkEndedEvent.lua", modName),
            string.format("Scripts/%s/UnequipGear.lua", modName),
            string.format("Scripts/%s/ItemCategory.lua", modName),
            string.format("Scripts/%s/utils/dd.lua", modName),
            string.format("Scripts/%s/utils/Inspect.lua", modName),
            string.format("Scripts/%s/SettingsCommands.lua", modName),
            string.format("Scripts/%s/MetaRole.lua", modName),
        }
        for _, script in ipairs(scripts) do
            local result = Script.LoadScript(script)
            if result ~= 1 then
                System.LogAlways("$4[" .. HelmetOffDialog.MOD_NAME .. ".ERROR] Unable to load script: " .. script)
            end
        end
        System.LogAlways("$5[" .. HelmetOffDialog.MOD_NAME .. ".INFO] All classes loaded.")
    end,
}

_G.HelmetOffDialog = _G.HelmetOffDialog or HelmetOffDialog

return HelmetOffDialog;