--- @class Equipment
--- @field new fun(self: Equipment, helmetOffDialog: HelmetOffDialog, log: Log, player: _G.player, equippedItem: EquippedItem, itemCategory: ItemCategory, unequipGear: UnequipGear): Equipment
--- @field putOnCoif fun(self: Equipment)
--- @field putOnHelmet fun(self: Equipment)
--- @field putOnHeadChainmail fun(self: Equipment)
--- @field putOnFirstRangedWeapon fun(self: Equipment)
--- @field putOnSecondRangedWeapon fun(self: Equipment)
--- @field log Log
--- @field unequipGear UnequipGear
local Equipment = {
    new = function(self, helmetOffDialog, log, player, unequipGear)
        if helmetOffDialog.__factories.equipment then
            return helmetOffDialog.__factories.equipment
        end
        local instance = {
            log = log,
            player = player,
            unequipGear = unequipGear,
            helmetOffDialog = helmetOffDialog,
            unequippedHelmet = nil,
            unequippedHeadChainmail = nil,
            unequippedCoif = nil,
            firstRangedWeapon = nil,
            secondRangedWeapon = nil
        }
        setmetatable(instance, { __index = self })
        helmetOffDialog.__factories.equipment = instance
        log:info("Equipment New instance created")
        return instance
    end,

    putOnHelmet = function(self)
        if self.unequippedHelmet then
            local item = ItemManager.GetItem(self.unequippedHelmet)
            local itemName = ItemManager.GetItemName(item.class)
            self.log:info("Putting on helmet: ", itemName)
            self.player.actor:EquipInventoryItem(self.unequippedHelmet)
            self.unequippedHelmet = nil
        end
    end,

    putOnHeadChainmail = function(self)
        if self.unequippedHeadChainmail then
            local item = ItemManager.GetItem(self.unequippedHeadChainmail)
            local itemName = ItemManager.GetItemName(item.class)
            self.log:info("Putting on head chainmail: ", itemName)
            self.player.actor:EquipInventoryItem(self.unequippedHeadChainmail)
            self.unequippedHeadChainmail = nil
        end
    end,

    putOnCoif = function(self)
        if self.unequippedCoif then
            local item = ItemManager.GetItem(self.unequippedCoif)
            local itemName = ItemManager.GetItemName(item.class)
            self.log:info("Putting on coif: ", itemName)
            self.player.actor:EquipInventoryItem(self.unequippedCoif)
            self.unequippedCoif = nil
        end
    end,

    takeOffHelmet = function(self, callback)
        --- @type Equipment
        local this = self
        this.log:info("Equipment.takeOffHelmet")
        this.unequipGear:takeOff("Helmet", function(unequippedHelmet)
            if unequippedHelmet then
                self.unequippedHelmet = unequippedHelmet
            end
            callback()
        end)
    end,

    takeOffHeadChainmail = function(self, callback)
        self.log:info("Equipment.takeOffHeadChainmail")
        self.unequipGear:takeOff("HeadChainmail", function(unequippedHeadChainmail)
            if unequippedHeadChainmail then
                self.unequippedHeadChainmail = unequippedHeadChainmail
            end
            callback()
        end)
    end,

    takeOffCoif = function(self, callback)
        self.log:info("Equipment.takeOffCoif")
        self.unequipGear:takeOff("Coif", function(unequippedCoif)
            if unequippedCoif then
                self.unequippedCoif = unequippedCoif
            end
            callback()
        end)
    end,

    takeOffFirstRangedWeapon = function(self, callback)
        self.log:info("Equipment.takeOffFirstRangedWeapon")
        self.unequipGear:takeOff("RangedWeapon", function(unequippedRangedWeapon)
            if unequippedRangedWeapon then
                self.firstRangedWeapon = unequippedRangedWeapon
            end
            callback()
        end)
    end,
    takeOffSecondRangedWeapon = function(self, callback)
        self.log:info("Equipment.takeOffSecondRangedWeapon")
        self.unequipGear:takeOff("RangedWeapon", function(unequippedRangedWeapon)
            if unequippedRangedWeapon then
                self.secondRangedWeapon = unequippedRangedWeapon
            end
            callback()
        end)
    end,

    putOnFirstRangedWeapon = function(self)
        if self.firstRangedWeapon then
            local item = ItemManager.GetItem(self.firstRangedWeapon)
            local itemName = ItemManager.GetItemName(item.class)
            self.log:info("Putting on first ranged weapon: ", itemName)
            self.player.actor:EquipInventoryItem(self.firstRangedWeapon)
            self.firstRangedWeapon = nil
        end
    end,
    putOnSecondRangedWeapon = function(self)
        if self.secondRangedWeapon then
            local item = ItemManager.GetItem(self.secondRangedWeapon)
            local itemName = ItemManager.GetItemName(item.class)
            self.log:info("Putting on second ranged weapon: ", itemName)
            self.player.actor:EquipInventoryItem(self.secondRangedWeapon)
            self.secondRangedWeapon = nil
        end
    end,

}

_G.HelmetOffDialog.ClassRegistry.Equipment = Equipment

return Equipment