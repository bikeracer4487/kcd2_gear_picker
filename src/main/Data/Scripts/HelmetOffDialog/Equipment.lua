local Log = HelmetOffDialog.Log

--- @class Equipment
--- @field new fun(self: Equipment, helmetOffDialog: HelmetOffDialog, player: _G.player, equippedItem: EquippedItem, itemCategory: ItemCategory, unequipGear: UnequipGear): Equipment
--- @field putOnCoif fun(self: Equipment)
--- @field putOnHelmet fun(self: Equipment)
--- @field putOnHeadChainmail fun(self: Equipment)
--- @field putOnFirstRangedWeapon fun(self: Equipment)
--- @field putOnSecondRangedWeapon fun(self: Equipment)
--- @field unequipGear UnequipGear
local Equipment = {
    new = function(self, helmetOffDialog, player, unequipGear)
        if helmetOffDialog.__factories.equipment then
            return helmetOffDialog.__factories.equipment
        end
        local instance = {
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
        Log.info("Equipment New instance created")
        return instance
    end,

    takeOffHelmet = function(self, callback)
        Log.info("Equipment.takeOffHelmet:called")
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
        Log.info("Equipment.takeOffHeadChainmail:called")
        self.unequipGear:takeOff("HeadChainmail", function(item)
            if item then
                self.unequippedHeadChainmail = item
            end
            callback()
        end)
    end,

    takeOffCoif = function(self, callback)
        Log.info("Equipment.takeOffCoif:called")
        self.unequipGear:takeOff("Coif", function(item)
            if item then
                self.unequippedCoif = item
            end
            callback()
        end)
    end,

    takeOffFirstRangedWeapon = function(self, callback)
        Log.info("Equipment.takeOffFirstRangedWeapon:called")
        self.unequipGear:takeOff("RangedWeapon", function(item)
            if item then
                self.firstRangedWeapon = item
            end
            callback()
        end)
    end,

    takeOffSecondRangedWeapon = function(self, callback)
        Log.info("Equipment.takeOffSecondRangedWeapon:called")
        self.unequipGear:takeOff("RangedWeapon", function(item)
            if item then
                self.secondRangedWeapon = item
            end
            callback()
        end)
    end,

    putOnCoif = function(self)
        Log.info("Equipment.putOnCoif:called")
        if nil == self.unequippedCoif then
            return
        end

        local item = ItemManager.GetItem(self.unequippedCoif)
        local itemName = ItemManager.GetItemName(item.class)
        Log.info("Putting on coif: ", itemName)
        self.player.actor:EquipInventoryItem(self.unequippedCoif)
        self.unequippedCoif = nil
    end,

    putOnHeadChainmail = function(self)
        Log.info("Equipment.putOnHeadChainmail:called")
        if nil == self.unequippedHeadChainmail then
            return
        end

        local item = ItemManager.GetItem(self.unequippedHeadChainmail)
        local itemName = ItemManager.GetItemName(item.class)
        Log.info("Putting on head chainmail: ", itemName)
        self.player.actor:EquipInventoryItem(self.unequippedHeadChainmail)
        self.unequippedHeadChainmail = nil
    end,

    putOnHelmet = function(self)
        Log.info("Equipment.putOnHelmet:called")
        if nil == self.unequippedHelmet then
            return
        end

        local item = ItemManager.GetItem(self.unequippedHelmet)
        local itemName = ItemManager.GetItemName(item.class)
        Log.info("Putting on helmet: ", itemName)
        self.player.actor:EquipInventoryItem(self.unequippedHelmet)
        self.unequippedHelmet = nil
    end,

    putOnFirstRangedWeapon = function(self)
        Log.info("Equipment.putOnFirstRangedWeapon:called")
        if nil == self.firstRangedWeapon then
            return
        end

        local item = ItemManager.GetItem(self.firstRangedWeapon)
        local itemName = ItemManager.GetItemName(item.class)
        Log.info("Putting on first ranged weapon: ", itemName)
        self.player.actor:EquipInventoryItem(self.firstRangedWeapon)
        self.firstRangedWeapon = nil
    end,

    putOnSecondRangedWeapon = function(self)
        Log.info("Equipment.putOnSecondRangedWeapon:called")
        if nil == self.secondRangedWeapon then
            return
        end

        local item = ItemManager.GetItem(self.secondRangedWeapon)
        local itemName = ItemManager.GetItemName(item.class)
        Log.info("Putting on second ranged weapon: ", itemName)
        self.player.actor:EquipInventoryItem(self.secondRangedWeapon)
        self.secondRangedWeapon = nil
    end,

}

_G.HelmetOffDialog.ClassRegistry.Equipment = Equipment

return Equipment