local Log = HelmetOffDialog.Log

--- @class Equipment
--- @field new fun(self: Equipment, player: _G.player, unequipGear: UnequipGear): Equipment
--- @field putOnCoif fun(self: Equipment)
--- @field putOnHelmet fun(self: Equipment)
--- @field putOnHeadChainmail fun(self: Equipment)
--- @field putOnFirstRangedWeapon fun(self: Equipment)
--- @field putOnSecondRangedWeapon fun(self: Equipment)
--- @field unequipGear UnequipGear
local Equipment = {
    new = function(self, player, unequipGear, itemManager)
        local instance = {
            player = player,
            unequipGear = unequipGear,
            itemManager = itemManager,
            unequippedHelmet = nil,
            unequippedHeadChainmail = nil,
            unequippedCoif = nil,
            firstRangedWeapon = nil,
            secondRangedWeapon = nil
        }
        setmetatable(instance, { __index = self })
        Log.info("Equipment New instance created")
        return instance
    end,

    takeOffHelmet = function(self, callback)
        Log.info("Equipment.takeOffHelmet:called")

        self.unequipGear:takeOff("Helmet", function(item)
            if item then
                self.unequippedHelmet = item
            end
            return callback("done")
        end)
    end,

    takeOffHeadChainmail = function(self, callback)
        Log.info("Equipment.takeOffHeadChainmail:called")
        self.unequipGear:takeOff("HeadChainmail", function(item)
            if item then
                self.unequippedHeadChainmail = item
            end
            return callback("done")
        end)
    end,

    takeOffCoif = function(self, callback)
        Log.info("Equipment.takeOffCoif:called")
        self.unequipGear:takeOff("Coif", function(item)
            if item then
                self.unequippedCoif = item
            end
            callback("done")
        end)
    end,

    takeOffFirstRangedWeapon = function(self, callback)
        Log.info("Equipment.takeOffFirstRangedWeapon:called")
        self.unequipGear:takeOff("RangedWeapon", function(takenOffItem)
            if takenOffItem then
                local item = self.itemManager.GetItem(takenOffItem)
                local itemName = self.itemManager.GetItemName(item.class)
                Log.info("Taking off ranged first weapon", itemName)
                self.firstRangedWeapon = takenOffItem
            end
            callback("done")
        end)
    end,

    takeOffSecondRangedWeapon = function(self, callback)
        Log.info("Equipment.takeOffSecondRangedWeapon:called")
        self.unequipGear:takeOff("RangedWeapon", function(takenOffItem)
            if takenOffItem then
                local item = self.itemManager.GetItem(takenOffItem)
                local itemName = self.itemManager.GetItemName(item.class)
                Log.info("Taking off ranged second weapon", itemName)
                self.secondRangedWeapon = takenOffItem
            end
            callback("done")
        end)
    end,

    putOnCoif = function(self)
        if nil == self.unequippedCoif then
            Log.info("Equipment.putOnCoif: Aborting due to no unequipped coif found")
            return
        end

        local item = self.itemManager.GetItem(self.unequippedCoif)
        local itemName = self.itemManager.GetItemName(item.class)
        Log.info("Putting on coif: ", itemName)

        if self.player.inventory:HasItem(self.unequippedCoif) then
            self.player.actor:EquipInventoryItem(self.unequippedCoif)
        else
            Log.info("Aborting because item not inventory")
        end

        self.unequippedCoif = nil
    end,

    putOnHeadChainmail = function(self)
        if nil == self.unequippedHeadChainmail then
            Log.info("Equipment.putOnHeadChainmail: Aborting due to no unequipped coif found")
            return
        end

        local item = self.itemManager.GetItem(self.unequippedHeadChainmail)
        local itemName = self.itemManager.GetItemName(item.class)
        Log.info("Putting on head chainmail: ", itemName)

        if self.player.inventory:HasItem(self.unequippedHeadChainmail) then
            self.player.actor:EquipInventoryItem(self.unequippedHeadChainmail)
        else
            Log.info("Aborting because item not inventory")
        end

        self.unequippedHeadChainmail = nil
    end,

    putOnHelmet = function(self)
        if nil == self.unequippedHelmet then
            Log.info("Aborting due to no unequipped helmet found")
            return
        end

        local item = self.itemManager.GetItem(self.unequippedHelmet)
        local itemName = self.itemManager.GetItemName(item.class)
        Log.info("Putting on helmet: ", itemName)

        if self.player.inventory:HasItem(self.unequippedHelmet) then
            self.player.actor:EquipInventoryItem(self.unequippedHelmet)
        else
            Log.info("Aborting because item not inventory")
        end

        self.unequippedHelmet = nil
    end,

    putOnFirstRangedWeapon = function(self)
        if nil == self.unequippedFirstRangedWeapon then
            Log.info("Aborting due to no first ranged weapon")
            return
        end

        local item = self.itemManager.GetItem(self.unequippedFirstRangedWeapon)
        local itemName = self.itemManager.GetItemName(item.class)
        Log.info("Putting on first ranged weapon: ", itemName)

        if self.player.inventory:HasItem(self.unequippedFirstRangedWeapon) then
            self.player.actor:EquipInventoryItem(self.unequippedFirstRangedWeapon)
        else
            Log.info("Aborting because item not inventory")
        end

        self.unequippedFirstRangedWeapon = nil
    end,

    putOnSecondRangedWeapon = function(self)
        if nil == self.unequippedSecondRangedWeapon then
            Log.info("Aborting due to no second ranged weapon")
            return
        end

        local item = self.itemManager.GetItem(self.unequippedSecondRangedWeapon)
        local itemName = self.itemManager.GetItemName(item.class)
        Log.info("Putting on second ranged weapon: ", itemName)
        self.player.actor:EquipInventoryItem(self.unequippedSecondRangedWeapon)
        self.unequippedSecondRangedWeapon = nil
    end,

}

_G.HelmetOffDialog.ClassRegistry.Equipment = Equipment

return Equipment