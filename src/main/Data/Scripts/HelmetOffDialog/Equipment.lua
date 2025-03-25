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

    takeOffHelmet = function(self, callback)
        self.log:info("Equipment.takeOffHelmet:called")
        --- @type Equipment
        local this = self

        this.unequipGear:takeOff("Helmet", function(item)
            if item then
                self.unequippedHelmet = item
            end
            callback()
        end)
    end,

    takeOffHeadChainmail = function(self, callback)
        self.log:info("Equipment.takeOffHeadChainmail:called")
        self.unequipGear:takeOff("HeadChainmail", function(item)
            if item then
                self.unequippedHeadChainmail = item
            end
            callback()
        end)
    end,

    takeOffCoif = function(self, callback)
        self.log:info("Equipment.takeOffCoif:called")
        self.unequipGear:takeOff("Coif", function(item)
            if item then
                self.unequippedCoif = item
            end
            callback()
        end)
    end,

    takeOffFirstRangedWeapon = function(self, callback)
        self.log:info("Equipment.takeOffFirstRangedWeapon:called")
        self.unequipGear:takeOff("RangedWeapon", function(item)
            if item then
                self.firstRangedWeapon = item
            end
            callback()
        end)
    end,

    takeOffSecondRangedWeapon = function(self, callback)
        self.log:info("Equipment.takeOffSecondRangedWeapon:called")
        self.unequipGear:takeOff("RangedWeapon", function(item)
            if item then
                self.secondRangedWeapon = item
            end
            callback()
        end)
    end,

    putOnCoif = function(self)
        self.log:info("Equipment.putOnCoif:called")
        if not self.unequippedCoif then
            return
        end

        local item = ItemManager.GetItem(self.unequippedCoif)
        local itemName = ItemManager.GetItemName(item.class)
        self.log:info("Putting on coif: ", itemName)
        self.player.actor:EquipInventoryItem(self.unequippedCoif)
        self.unequippedCoif = nil
    end,

    putOnHeadChainmail = function(self)
        self.log:info("Equipment.putOnHeadChainmail:called")
        if not self.unequippedHeadChainmail then
            return
        end

        local item = ItemManager.GetItem(self.unequippedHeadChainmail)
        local itemName = ItemManager.GetItemName(item.class)
        self.log:info("Putting on head chainmail: ", itemName)
        self.player.actor:EquipInventoryItem(self.unequippedHeadChainmail)
        self.unequippedHeadChainmail = nil
    end,

    putOnHelmet = function(self)
        self.log:info("Equipment.putOnHelmet:called")
        if not self.unequippedHelmet then
            return
        end

        local item = ItemManager.GetItem(self.unequippedHelmet)
        local itemName = ItemManager.GetItemName(item.class)
        self.log:info("Putting on helmet: ", itemName)
        self.player.actor:EquipInventoryItem(self.unequippedHelmet)
        self.unequippedHelmet = nil
    end,

    putOnFirstRangedWeapon = function(self)
        self.log:info("Equipment.putOnFirstRangedWeapon:called")
        if not self.firstRangedWeapon then
            return
        end

        local item = ItemManager.GetItem(self.firstRangedWeapon)
        local itemName = ItemManager.GetItemName(item.class)
        self.log:info("Putting on first ranged weapon: ", itemName)
        self.player.actor:EquipInventoryItem(self.firstRangedWeapon)
        self.firstRangedWeapon = nil
    end,

    putOnSecondRangedWeapon = function(self)
        self.log:info("Equipment.putOnSecondRangedWeapon:called")
        if not self.secondRangedWeapon then
            return
        end

        local item = ItemManager.GetItem(self.secondRangedWeapon)
        local itemName = ItemManager.GetItemName(item.class)
        self.log:info("Putting on second ranged weapon: ", itemName)
        self.player.actor:EquipInventoryItem(self.secondRangedWeapon)
        self.secondRangedWeapon = nil
    end,

}

_G.HelmetOffDialog.ClassRegistry.Equipment = Equipment

return Equipment