--- @class HelmetOffDialog @global
local HelmetOffDialog = {
    MOD_NAME = "__DYNAMICALLY_INJECTED__",
    HOD_ENVIRONMENT = "__DYNAMICALLY_INJECTED__",

    ClassRegistry = {},
    __factories = {},

    --- @type Config
    config = function(self)
        --- @type HelmetOffDialog
        local this = self

        if this.__factories.config then
            return this.__factories.config
        end

        --- @type Config
        local Config = this.ClassRegistry.Config
        this.__factories.config = Config:new(HelmetOffDialog.HOD_ENVIRONMENT)

        return this.__factories.config
    end,
    error = function(self)
        --- @type HelmetOffDialog
        local this = self

        if this.__factories.error then
            return this.__factories.error
        end
        --- @type Error
        local Error = this.ClassRegistry.Error
        this.__factories.error = Error:new()
        return this.__factories.error
    end,
    equipment = function(self)
        --- @type HelmetOffDialog
        local this = self
        --- @type Equipment
        if this.__factories.equipment then
            return this.__factories.equipment
        end
        local Equipment = this.ClassRegistry.Equipment
        this.__factories.equipment = Equipment:new(_G.player, this:unequipGear())
        return this.__factories.equipment
    end,
    unequipGear = function(self)
        --- @type HelmetOffDialog
        local this = self
        --- @type UnequipGear
        local UnequipGear = this.ClassRegistry.UnequipGear

        if this.__factories.unequipGear then
            return this.__factories.unequipGear
        end

        this.__factories.unequipGear = UnequipGear:new(
                _G.player, this:equippedItem(), this:itemCategory(), _G.ItemManager
        )

        return this.__factories.unequipGear
    end,
    talkEndedEvent = function(self)
        --- @type HelmetOffDialog
        local this = self

        if this.__factories.talkEndedEvent then
            return this.__factories.talkEndedEvent
        end

        --- @type TalkEndedEvent
        local TalkEndedEvent = this.ClassRegistry.TalkEndedEvent
        this.__factories.talkEndedEvent = TalkEndedEvent:new(
                this:config(), this:equipment(), this:timedTrigger(), _G.player
        )
        return this.__factories.talkEndedEvent
    end,
    metaRole = function(self)
        --- @type HelmetOffDialog
        local this = self

        if this.__factories.MetaRole then
            return this.__factories.MetaRole
        end

        --- @type MetaRole
        local MetaRole = this.ClassRegistry.MetaRole
        this.__factories.MetaRole = MetaRole:new(_G.System, _G.player)

        return this.__factories.MetaRole
    end,
    onTalkEvent = function(self)
        --- @type HelmetOffDialog
        local this = self
        if this.__factories.onTalkEvent then
            return this.__factories.onTalkEvent
        end
        --- @type OnTalkEvent
        local OnTalkEvent = this.ClassRegistry.OnTalkEvent
        this.__factories.onTalkEvent = OnTalkEvent:new(
                this:equipment(),
                this:talkEndedEvent(),
                this:metaRole(),
                this:config()
        )
        return this.__factories.onTalkEvent
    end,
    timedTrigger = function(self)
        --- @type HelmetOffDialog
        local this = self

        if this.__factories.timedTrigger then
            return this.__factories.timedTrigger
        end

        --- @type TimedTrigger
        local TimedTrigger = this.ClassRegistry.TimedTrigger
        this.__factories.timedTrigger = TimedTrigger:new(_G.Script)

        return this.__factories.timedTrigger
    end,
    equippedItem = function(self)
        --- @type HelmetOffDialog
        local this = self

        if this.__factories.equippedItem then
            return this.__factories.equippedItem
        end

        --- @type EquippedItem
        local EquippedItem = this.ClassRegistry.EquippedItem
        this.__factories.equippedItem = EquippedItem:new(_G.player, _G.Script)

        return this.__factories.equippedItem
    end,
    itemCategory = function(self)
        --- @type HelmetOffDialog
        local this = self
        if this.__factories.itemCategory then
            return this.__factories.itemCategory
        end
        --- @type ItemCategory
        local ItemCategory = this.ClassRegistry.ItemCategory
        this.__factories.itemCategory = ItemCategory:new(_G.ItemManager)
        return this.__factories.itemCategory
    end,
    commands = function(self)
        --- @type HelmetOffDialog
        local this = self
        if this.__factories.commands then
            return this.__factories.commands
        end
        --- @type Commands
        local Commands = this.ClassRegistry.Commands
        this.__factories.commands = Commands:new(_G.System, this:config())
        return this.__factories.commands
    end,

    init = function(self)
        --- @type HelmetOffDialog
        local this = self
        this.__factories = {}

        local modName = "HelmetOffDialog"
        local scripts = {
            string.format("Scripts/%s/utils/Log.lua", modName),
            string.format("Scripts/%s/utils/Error.lua", modName),
            string.format("Scripts/%s/TimedTrigger.lua", modName),
            string.format("Scripts/%s/Config.lua", modName),
            string.format("Scripts/%s/Equipment.lua", modName),
            string.format("Scripts/%s/EquippedItem.lua", modName),
            string.format("Scripts/%s/OnTalkEvent.lua", modName),
            string.format("Scripts/%s/TalkEndedEvent.lua", modName),
            string.format("Scripts/%s/UnequipGear.lua", modName),
            string.format("Scripts/%s/ItemCategory.lua", modName),
            string.format("Scripts/%s/utils/dd.lua", modName),
            string.format("Scripts/%s/utils/Inspect.lua", modName),
            string.format("Scripts/%s/Commands.lua", modName),
            string.format("Scripts/%s/MetaRole.lua", modName),
            string.format("Scripts/%s/Commands.lua", modName),
        }
        for _, script in ipairs(scripts) do
            local result = Script.LoadScript(script)
            if result ~= 1 then
                System.LogAlways("$4[" .. HelmetOffDialog.MOD_NAME .. ".ERROR] Unable to load script: " .. script)
            end
        end
        HelmetOffDialog.Log.info("All classes loaded.")
    end,
}

_G.HelmetOffDialog = _G.HelmetOffDialog or HelmetOffDialog

return HelmetOffDialog;